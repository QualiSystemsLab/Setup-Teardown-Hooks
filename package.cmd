mkdir pkg
mkdir pkg\Configuration
mkdir pkg\DataModel
mkdir "pkg\Topology Scripts"

copy Setup_Teardown_Hooks_Package\metadata.xml                                                                     pkg
copy Setup_Teardown_Hooks_Package\DataModel\datamodel.xml                                                          pkg\DataModel
copy "Setup_Teardown_Hooks_Package\Resource Scripts\*"                                                            "pkg\Resource Scripts"


cd "Setup_Teardown_Hooks_Package\Topology Scripts\hook_setup"
set fn="..\..\..\pkg\Topology Scripts\hook_setup.zip"
"c:\Program Files\7-Zip\7z.exe" a %fn% *
cd ..\..\..

cd "Setup_Teardown_Hooks_Package\Topology Scripts\hook_teardown"
set fn="..\..\..\pkg\Topology Scripts\hook_teardown.zip"
"c:\Program Files\7-Zip\7z.exe" a %fn% *
cd ..\..\..



cd pkg
set fn="..\Setup_Teardown_Hooks_Package.zip"
del %fn%
"c:\Program Files\7-Zip\7z.exe" a %fn% *
cd ..

rmdir /s /q pkg
