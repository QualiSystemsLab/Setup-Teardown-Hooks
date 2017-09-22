# Setup-Teardown-Hooks

Setup and Teardown scripts based on the refactored 8.1 default orchestration.

These scripts can replace the default Setup and Teardown scripts as the default for all environments, 
without interfering with the standard functionality. They register handlers that only have an effect if 
specially named functions on resources or services are also deliberately created.

During the enhanced Setup and Teardown processes, we automatically call hook functions whenever they 
exist on resources and services in the reservation. Driver functions and scripts are both supported. 

Your hook function will be called in the corresponding phase if the function name contains one of the 
following keywords:

- orch_hook_pre_setup*
- orch_hook_during_preparation
- orch_hook_post_preparation
- orch_hook_during_provisioning
- orch_hook_post_provisioning
- orch_hook_during_connectivity
- orch_hook_post_connectivity
- orch_hook_during_configuration
- orch_hook_post_configuration
- orch_hook_post_setup*
- orch_hook_pre_teardown
- orch_hook_during_teardown
- orch_hook_post_teardown*

*Faked unofficial phases that are called directly instead of registered in the orchestration 
&mdash; see source

The orch_hook_during_* hook functions will be executed in parallel with other parts of the default orchestration. 
For example, a hook named my_xyz_orch_hook_during_provisioning will run in parallel with app deployments. 


You can have multiple hooks in different phases, hooks on any number of resources and services, 
or even multiple hooks in the same phase even for the same resource or service.


To add multiple hooks in the same phase, just give them distinct names that all contain the hook keyword:

    def my_orch_hook_pre_setup_stuff(self, context):
        # ...
        
    def my_orch_hook_pre_setup_other_stuff(self, context):
        # ...
        
        
All hooks within a phase are executed in parallel threads with ExecuteCommand.

If a hook adds a resource or service to the reservation in some phase, and the new item implements a hook itself in
that same phase, it will be called in another round of processing before the end of the phase. But note that if the 
newly added component has hooks for earlier phases, they will not be called.

If you expect potential conflicts between concurrent updates to the reservation, especially involving connectors,
consider the reservation mutex technique here: https://github.com/ericrqs/Reservation-Mutex-Lock

## Suggested use
If you have functionality you need to run at some point during Setup or Teardown, instead of modifying Setup, 
you can implement the function in a hook on a service. To add the feature to any blueprint, you can just 
add the service. This extends to multiple independent services. The purpose of hooks is to improve the 
composability of multiple automation packages and reduce programming effort when you just want to run prepackaged
code.

Some potential uses:

- A resource that automatically configures itself at the start of a reservation
- An error handler service that inspects the live status of all resources in the reservation and the activity feed
during teardown to detect failed resources
- A service representing a complex multi-app deployment that &mdash;
    - adds multiple existing apps to the reservation before provisioning
    - moves connectors from itself onto the apps
    - lets the apps be deployed along with the others by the default Setup provisioning 
    - lets the connectors be applied by the default Setup connectivity phase


There is no way to control the order of hooks within the same phase. They will be run simultaneously in parallel.
Hooks should be designed with the expectation that their order within the phase is unpredictable. A trick to
get around this mechanism is to write one service hook that adds another service with another hook in the same phase. 
 


The implementation is in the form:

    One function 'f' that calls all hooks in a particular phase
        do
            scan the reservation for all hook functions that exist
            run all uncalled hooks in parallel threads with ExecuteCommand
            join all threads
            # some hooks may have added items to the reservation that have more hooks
        until no uncalled hooks were found
    Multiple registrations of 'f' with different hook names

Note that in the orchestration script documentation, the second argument of a registered handler function is
usually a list of components. It is actually treated by the system as an arbitrary opaque object. 
Here we pass a string like 'orch_hook_pre_setup' instead.



To enhance these hook Setup and Teardown scripts, just add code at the end. Any additional functions you register
will run in parallel with the hooks. If you disable a phase (e.g. preparation), the hooks for that phase will
also be disabled. 