####################
# Set up ADDS w/PS #
####################

# SET STATIC IP #
# PATCH OS #

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
sconfImport-Module ADDSDeployment
Install-ADDSForest

# Verify DNS Server Role is installed
Get-WindowsFeature -Name 'DNS'
