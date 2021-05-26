# Connect Azure Account
Connect-AzAccount

# Create a new lab
New-AzResourceGroupDeployment -ResourceGroupName "TestRG" -TemplateFile .\01-Create-DevTest-Lab_Template.json -regionId "northeurope" -nameFromTemplate "NewLab"