# Windows Activation
This script is designed to activate all versions of Windows using genuine Generic Volume License Keys from Microsoft
## Usage
The script must be run in an elevated powershell window
### Basic Execution
The script can be run using the `iwr` and `iex` powershell commands
```powershell
iwr "https://raw.githubusercontent.com/ToxicMonster/Windows-Activation/main/activate.ps1" | iex
```
### Override Current Activation
The current product key and activation status can be overwritten using the `-OVERWRITE` switch
```powershell
.\activate.ps1 -OVERWRITE
```
### Specify GVLK Keys
A custom JSON file can be specified to retrieve keys from using the `-GVLK` parameter
```powershell
.\activate.ps1 -GVLK .\config\gvlk.json
```
#### Key Format
The JSON File must be formatted using the Windows Product Name and key
```json
{
    "Windows Product Name": "GVLK"
}
```
*Note: Some Windows OS names are not the same as their product name. For example Windows 11 has the same product name as Windows 10*
### Specify KMS Server
A custom KMS server can be specified using the `-KMS` parameter
```powershell
.\activate.ps1 -KMS "kms.toxicmonster.net"
```
