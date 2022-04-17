@echo off

set project_name=main

mkdir build
pushd build

rem Set this value to the location of rc.exe under the VC directory
set rc_directory="C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64

rem Set this value to the location of ml64.exe under the VC directory
set ml_directory="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

rem Set this value to the location of link.exe under the VC directory
set link_directory="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64

%rc_directory%\rc.exe" ..\resource\resource.rc
move ..\resource\resource.res .\

%ml_directory%\ml64.exe" /c /Cp /Cx /Fm /FR /W2 /Zd /Zf /Zi ..\source\%project_name%.asm > errors.txt

rem %link_directory%\link.exe" %project_name%.obj resource.res /debug:full /opt:ref /opt:noicf /largeaddressaware:no /def:..\source\%project_name%.def /entry:main /machine:x64 /map /out:%project_name%.exe /PDB:%project_name%.pdb /subsystem:windows,6.0 "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64\kernel32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64\user32.lib"
%link_directory%\link.exe" %project_name%.obj resource.res /debug:full /opt:ref /opt:noicf /largeaddressaware:no /def:..\source\%project_name%.def /entry:main /machine:x64 /map /out:%project_name%.exe /PDB:%project_name%.pdb /subsystem:console "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64\kernel32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64\user32.lib"
type errors.txt

popd
