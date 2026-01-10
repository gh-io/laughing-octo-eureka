class JR_sde(par={})[source]
Jansen-Rit model C++ implementation.

Parameters:
par: dict
Including the following: - A : [mV] determine the maximum amplitude of the excitatory PSP (EPSP) - B : [mV] determine the maximum amplitude of the inhibitory PSP (IPSP) - a : [Hz] 1/tau_e,  of the reciprocal of the time constant of passive membrane and all other spatially distributed delays in the dendritic network - b : [Hz] 1/tau_i - r [mV] the steepness of the sigmoidal transformation. - v0 parameter of nonlinear sigmoid function - vmax parameter of nonlinear sigmoid function - C_i [list or np.array] average number of synaptic contacts in th inhibitory and excitatory feedback loops - noise_amp - noise_std
dt [second] integration time step
t_initial [s] initial time
t_end [s] final time
method [str] method of integration
t_transition [s] time to reach steady state
dim [int] dimention of the system
valid_params = ['noise_seed', 'seed', 'G', 'weights', 'A', 'B', 'a', 'b', 'noise_mu', 'noise_std', 'vmax', 'v0', 'r', 'C0', 'C1', 'C2', 'C3', 'dt', 'method', 't_transition', 't_end', 'control', 'output', 'RECORD_AVG', 'initial_state']
check_parameters(par)[source]
Check if the parameters are valid.
get_default_parameters()[source]
return default parameters for the Jansen-Rit sde model.
set_initial_state()[source]
Set initial state for the system of JR equations with N nodes.
prepare_input()[source]
prepare input parameters for passing to C++ engine.
run(par={}, x0=None, verbose=False)[source]
Integrate the system of equations for Jansen-Rit sde model.

Parameters:
par: dict
parameters to control the Jansen-Rit sde model.
x0: np.array
initial state
verbose: bool
print the message if True
Returns:
dict
t : time series
x : state variables
class JR_sdde(par={})[source]
valid_params = ['weights', 'delays', 'dt', 't_end', 'G', 'A', 'a', 'B', 'b', 'mu', 'nstart', 't_end', 't_transition', 'sigma', 'C', 'record_step', 'C0', 'C1', 'C2', 'C3', 'vmax', 'r', 'v0', 'output', 'sti_ti', 'sti_duration', 'sti_amplitude', 'sti_gain', 'noise_seed', 'seed', 'method']
check_parameters(par)[source]
check if the parameters are valid
get_default_parameters()[source]
get default parameters for the system of JR equations.
prepare_stimulus(sti_gain, sti_ti)[source]
prepare stimulation parameteres
set_initial_state()[source]
set initial state for the system of JR equations with N nodes.
prepare_input()[source]
prepare input parameters for C++ code.
run(par={}, x0=None, verbose=False)[source]
Integrate the system of equations for Jansen-Rit model.
check_sequence(x, n)[source]
check if x is a scalar or a sequence of length n

Parameters:
x: scalar or sequence of length n
n: number of nodes
Returns:
x: sequence of length n
set_initial_state(nn, seed=None)[source]
set initial state for the system of JR equations with N nodes.

Parameters:
nn: number of nodes
seed: random seed
Returns:
y: initial state of length 6N
