####
#
# Password Set file is required for the MA to function, however is emptry as no password capabilities are required.
#
####
param
(
 $Username,
 $Password,
 $Credentials,
 $Action, # will be set to either 'Set' or 'Change'
 $OldPassword,
 $NewPassword,
 [switch] $UnlockAccount,
 [switch] $ForceChangeAtLogOn,
 [switch] $ValidatePassword
)
BEGIN
{
}
PROCESS
{

}
END
{
}