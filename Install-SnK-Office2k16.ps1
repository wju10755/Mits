if(-not(Test-Path -Path "c:\temp")) {
    New-Item -ItemType Directory -Path "c:\temp"
}

Invoke-WebRequest -URI "https://skgeneralstorage.blob.core.windows.net/o2k16pp/O2k16pp.zip" -OutFile "c:\temp\o2k16pp.zip"

Expand-Archive -Path c:\temp\o2k16pp.zip -DestinationPath c:\temp\o2k16pp
set-location -path "c:\temp\o2k16pp\Office2016_ProPlus"

# Create the configuration XML content
$xmlContent = @"
<Configuration>
  <Add OfficeClientEdition="32" Channel="PerpetualVL2019">
    <Product ID="ProPlusRetail">
      <Language ID="en-us" />
    </Product>
  </Add>
  <Property Name="AUTOACTIVATE" Value="1"/>
  <Property Name="PIDKEY" Value="24KNC-3YFQ6-8V33B-YQ8FF-CR4HM"/>
  <Display Level="None" AcceptEULA="TRUE"/>
</Configuration>
"@

# Create the configuration XML file
$xmlContent | Out-File -FilePath "c:\temp\o2k16pp\Office2016_ProPlus\configuration.xml"

# Install Office
start-process .\setup.exe /confige .\configuration.xml

start-process 'c:\temp\o2k16pp\Office2016_ProPlus\setup.exe /configure' 'c:\temp\o2k16pp\Office2016_ProPlus\configuration.xml'

Start-Process -FilePath 'c:\temp\o2k16pp\Office2016_ProPlus\setup.exe' -ArgumentList '/config', 'c:\temp\o2k16pp\Office2016_ProPlus\configuration.xml'


# Remove the installation files
#Remove-Item -Path "c:\temp\o2k16pp.zip" -Force
#Remove-Item -Path "c:\temp\o2k16pp" -Recurse -Force

# Remove the configuration XML file
#Remove-Item -Path "c:\temp\o2k16pp\Office2016_ProPlus\configuration.xml" -Force