# Compute EEG leadfield using the standard (CG-) FEM approach,
# in a realistic volumetric tetrahedral 6 compartment head model
# with the Venant source model using the transfer matrix apporach

import sys
import os

current = os.path.dirname(os.path.realpath(__file__))
parent = os.path.dirname(current)
sys.path.append(parent)

import numpy as np
import duneuropy as dp
import util

import scipy.io

# Define input files
folder_input = os.path.join(parent,'duneuropy/Data')
folder_output = os.path.join(parent,'duneuropy/DataOut')
# grid_filename = os.path.join(folder_input, 'realistic_tet_mesh_6c.msh')

realistic_head_model_filename = os.path.join(folder_input, 'realistic_head_model.mat')
#electrode_filename = os.path.join(folder_input, 'realistic_electrodes_fitted.txt')
electrode_filename = os.path.join(folder_input, 'electrodes.elc')
dipoles_filename = os.path.join(folder_input, 'dipoles.mat')
tensor_filename = os.path.join(folder_input, 'tensors.mat')

ele_filename = os.path.join(folder_input, 'ele.mat')

# head model properties
realistic_head_model = scipy.io.loadmat(realistic_head_model_filename)


labels = realistic_head_model['labels'] - 1
nodes =  realistic_head_model['nodes']
elements =  scipy.io.loadmat(ele_filename)['ele']


cond_ratio = 3.6;   #conductivity ratio according to Akhtari et al., 2002
cond_compacta = (10**4)*np.array([8, 16, 24, 28, 31, 41, 55, 70, 83, 167, 330])
cc=4

conductivity = np.array([0.43, cond_compacta[cc], cond_ratio*cond_compacta[cc], 1.79, 0.33, 0.14])

tensors = scipy.io.loadmat(tensor_filename)['tensors'].T

# print('Elements:', '({0}, {1})'.format(len(elements),len(elements[0])))
# print('Nodes:','({0}, {1})'.format(len(nodes),len(nodes[0])))
# print('Labels:','({0}, {1})'.format(len(labels),len(labels[0])))
# print('Conductivities:','({0},)'.format(len(conductivity)))
# print('Tensors:',tensors.shape)



# Create MEEG driver
# We create the driver object which will read the mesh along with the conductivity tensors from the provided files
config = {
    'type' : 'fitted',
    'solver_type' : 'cg',
    'element_type' : 'tetrahedron',
    'volume_conductor' : {
        'grid' : {
            'elements' :  elements,
            'nodes' : nodes
        },
        'tensors' : {
            'labels' : labels ,
            'conductivities' : conductivity,
            #'tensors' : tensors
        }
    },
    'solver' : {
        'verbose' : 1
    }
}
driver = dp.MEEGDriver3d(config)


# Read and set electrode positions
# When projecting the electrodes, we choose the closest nodes
electrodePositions = util.read_electrodes(electrode_filename)
electrodes = [dp.FieldVector3D(x) for x in electrodePositions]
electrode_config = {
    'type' : 'closest_subentity_center',
    'codims' : [3]
}
driver.setElectrodes(electrodes, electrode_config)

# V. Compute EEG leadfield
# Compute the transfer matrix
transfer_config = {
    'solver' : {
        'reduction' : 1e-10
    }
}
tm = driver.computeEEGTransferMatrix(transfer_config)
tm_eeg = np.array(tm[0])

# (optional) save the transfer matrix
filename = os.path.join(folder_output, 'transfer_realistic_tet_cg.npy')
np.save(filename, tm_eeg)

# (optional) load the transfer matrix
# filename = os.path.join(folder_input, 'transfer_realistic_tet_cg.npy')
# tm_eeg = np.load(filename, allow_pickle=True)

# Create source model configurations (Partial integration St. Venant, Subtraction, Whitney)
source_model_config = {
    'type' : 'venant',
    'numberOfMoments' : 3,
    'referenceLength' : 20,
    'weightingExponent' : 1,
    'relaxationFactor' : 1e-6,
    'restricted' : False,
    'mixedMoments' : False,
    'restrict' : True,
    'initialization' : 'closest_vertex'
}

# Load dipoles 
#dipoles = [dp.Dipole3d([23.4541, 30, 100.716], [1, 0, 0])]
dipoles =  scipy.io.loadmat(dipoles_filename)['cd_matrix']

dipPos = list()
dipMom = list()
for i in range(len(dipoles)):
    dipPos.append(dp.FieldVector3D(dipoles[i][:3].tolist()))
    dipMom.append(dp.FieldVector3D(dipoles[i][3:].tolist()))

dipoles = [dp.Dipole3d(p,m) for p,m in zip(dipPos, dipMom)]

pvtk = dp.PointVTKWriter3d(dipPos, True)
pvtk.addVectorData('mom', dipMom)
pvtk.write(os.path.join(folder_output,'dipoles'))


# Apply the transfer matrix
lf = driver.applyEEGTransfer(tm_eeg, dipoles, {
                    'source_model' : source_model_config,
                    'post_process' : True,
                    'subtract_mean' : True
                })
solution = np.array(lf[0])
    


# Vizualization of output (mesh, the first dipole and the resulting potential of this dipole at the electrodes)
driver.write({
    'format' : 'vtk',
    'filename' : os.path.join(folder_output, 'realistic_cg_tet_transfer_headmodel')
})

# pvtk = dp.PointVTKWriter3d(dipoles[0])
# pvtk.write(os.path.join(folder_output,'realistic_cg_tet_transfer_testdipole'))

pvtk = dp.PointVTKWriter3d(electrodes, True)
pvtk.addScalarData('potential', solution[0]) 
pvtk.write(os.path.join(folder_output, 'realistic_cg_tet_transfer_lf_venant'))

# print a list of relevant publications
driver.print_citations()
