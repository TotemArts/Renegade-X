# Renegade-X

This repository contains Unrealscript and DLL source code *only*. It does not contain any of the executables or assets.

To setup, first download the SDK from http://renegade-x.com/download.php, then checkout the repository into an empty folder. Copy all folders exept the "Development" folder from the downloaded SDK zip into the repository directory. The directory structure should appear like so:

- Renegade-X
  - Binaries        <- Git Ignored (From SDK)
  - Development     <- Versioned (From GIT)
  - Engine          <- Git Ignored (From SDK)
  - Example Assets  <- Git Ignored (From SDK)
  - UDKGame        <- Git Ignored (From SDK)

Note: The master branch contains the latest code, as it is being developed by the team. As such, it may reference assets that have not yet been released in the SDK, which can cause compile errors, warnings, and unexpeced behaviour. Therefore, It's recommended to checkout the branch that coincides with the version of the SDK you have downloaded.
