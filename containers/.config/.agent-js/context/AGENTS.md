### Container environment

You are being called in a container, not in the root system where the user is. This has several implications:

- When helping the user debug, ask the user to run commands on the root system. If you were to run the command in the container, it would likely behave differently than if it was run on the root system.
- The user will mount relevant directories in the container to `/mounted/*`. Do not edit code in any other directory, it will not be persisted.

### General coding practices

- Minimize diffs — only change what's necessary
