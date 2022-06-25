#!/bin/bash
######User Settings Start######
export version=1.19
export serverPath=/mnt/main/Cache/Paper
######User Settings End######

######Function Start######
#Build Spigot
function buildSpigot(){
    url="https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
    checkFile=BuildTools.jar
    echo "Downloading BuildTools for Spigot..."
    wget ${url} >/dev/null 2>/dev/null
    java -jar $checkFile nogui --rev ${version} >/dev/null
    rm -rf ${checkConfig}
    mv spigot-*.jar Spigot-latest.jar
    update Spigot-latest.jar
}

#testPackageManager
function detectPackageManager(){
    echo "Detecting package manager..."
    if [[ $(sudo apt install 2>/dev/null) ]]; then
        echo 'Detected apt'
        return apt
    elif [[ $(sudo pacman -h 2>/dev/null) ]]; then
        echo 'Detected pacman'
        return pacman
    elif [[ $(sudo dnf install 2>/dev/null) ]]; then
        echo 'Detected dnf'
        return dnf
    else
        return unknown
    fi
}
#checkConfig
checkConfig(){
    if [ ! ${version} ]; then
        echo '$version not set, please enter your desied version:'
        read version
    fi
    if [ ! ${serverPath} ]; then
        echo "Warning! serverPath not set, please enter complete path to your server:"
        read serverPath
    fi
    if [ ! $build ]; then
        export build=500
    fi
}
#removeJarFile
function clean(){
    echo "Cleaning..."
    rm -rf *.jar
    rm -rf *.check
    rm -rf *.1
    rm -rf *.2
}
#moveFile
function update(){
    echo "Updating jar file..."
    if [[ $@ = Paper-latest.jar ]]; then
        mv Paper-latest.jar $serverPath
    elif [[ $@ = Spigot-latest.jar ]]; then
        mv $@ ${serverPath}/$@
    else
        mv $@ ${serverPath}/plugins/
    fi
}
#versionCompare
function versionCompare(){
    echo "Making sure you're up to date..."
    if [ $isPlugin = true ]; then
        checkPath="${serverPath}/plugins"
    else
        checkPath="${serverPath}"
    fi
    diff -q "${checkPath}/${checkFile}" "${checkFile}"
    return $?
}
#integrityProtect
function integrityProtect(){
    echo "Checking file integrity..."
    if [[ $@ =~ "unsafe" ]]; then
        echo "Warning! Default protection disabled. USE AT YOUR OWN RISK!"
        return 0
    else
        echo "Verifing ${checkFile}"
        if [ ${isPlugin} = false ]; then
            checkFile=Paper-latest.jar
            wget $url >/dev/null 2>/dev/null
            mv paper-*.jar Paper-latest.jar.check
            diff -q Paper-latest.jar.check Paper-latest.jar
            return $?
        else
            mv $checkFile "${checkFile}.check"
            wget $url >/dev/null 2>/dev/null
            diff -q $checkFile "${checkFile}.check"
            return $?
        fi
    fi
    if [ $? = 1 ]; then
        echo "Checking job done, repairing ${checkFile}."
        redownload
    else
        echo "Ckecking job done, ${ckeckFile} verified."
        clean
    fi
}
function redownload(){
    clean
    if [ ${isPlugin} = false ]; then
        checkFile=Paper-latest.jar
        wget $url >/dev/null 2>/dev/null
        mv paper-*.jar Paper-latest.jar
        integrityProtect
    else
        wget $url >/dev/null 2>/dev/null
        integrityProtect
    fi
}
#pluginUpdate
function pluginUpdate(){
    echo "Updating ${checkFile}"
    if [ $@ = Floodgate ]; then
        pluginName=Floodgate
        export url="https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar"
    elif [ $@ = Geyser ]; then
        pluginName=Geyser
        url="https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar"
    elif [ $@ = SAC ]; then
        pluginName=SAC
        url="https://www.spigotmc.org/resources/soaromasac-lightweight-cheat-detection-system.87702/download?version=455200"
    elif [ $@ = MTVehicles ]; then
        pluginName="$@"
        url="https://www.spigotmc.org/resources/mtvehicles-vehicle-plugin-free-downloadable.80910/download?version=452759"
    else
        echo "Sorry, but we don't have your plugin's download url. Please wait for support~"
    fi
    echo "Downloading ${pluginName}"
    wget $url >/dev/null 2>/dev/null
    isPlugin=true
}
#systemUpdate
function systemUpdate(){
    if [[ $@ =~ "systemupdate" ]]; then
        echo "Notice: Script will try to do a full system update"
        if [ `whoami` = root ]; then
            detectPackageManager
            if [ $? = apt ]; then
                echo "Updating using apt..."
                apt -y full-upgrade
            elif [ $? = dnf ]; then
                echo "Updating using dnf..."
                dnf -y update
            elif [ $? = pacman ]; then
                echo "Updating using pacman..."
                pacman --noconfirm -Syyu
            else
                unset packageManager
                echo "Package Manager not found! Enter command to update or type 'skip' to skip"
                read packageManager
                if [ ! ${packageManager} = skip ]; then
                    ${packageManager}
                else
                    echo "Skipping"
                fi
            fi
        else
            echo "System Update Failed! You are running under `whoami`"
        fi
    fi
}

#buildPaper
function buildPaper(){
    while [ ! -f paper-*.jar ]; do
        export build=`expr ${build} - 1`
        echo "Testing build ${build}"
        url="https://papermc.io/api/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar"
        wget $url >/dev/null 2>/dev/null
    done
    echo "Downloaded build ${build}."
    if [ -f paper-*.jar ]; then
        mv paper-*.jar Paper-latest.jar
    fi
    export isPlugin=false
    export checkFile=Paper-latest.jar
    integrityProtect
    versionCompare
    if [ $? = 0 ]; then
        echo "You're up to date."
        clean
    else
        echo "Updating Paper..."
        update Paper-latest.jar
    fi
    clean
}

#32-bit Warning
function checkBit(){
    getconf LONG_BIT
    return $?
    if [ $? = 64 ]; then
        echo "Running on 64-bit system."
    elif [ $? = 32 ]; then
        if [[ $@ =~ "unsafe" ]]; then
            echo "Warning at `date`, running on 32-bit system may encounter unexpected problems."
        else
            echo "32-bit system detected, script is terminating..."
            exit 2
        fi
    fi
}

function main(){
    echo "Hello! `whoami` at `date`"
    checkBit
    echo "Reading settings"
    clean
    checkConfig

    ######Paper Update Start######
    echo "Starting auto update at `date`"
    cd ${serverPath}/Update/
    if [[ $@ =~ "paper" ]]; then
        buildPaper
    fi
    ######Paper Update End######

    ######Spigot Update Start######
    if [[ $@ =~ "spigot" ]]; then
        buildSpigot
        update
    fi
    ######Plugin Update Start######
    if [[ $@ =~ "mtvehicles" ]]; then
        isPlugin=true
        pluginUpdate MTVehicles
        checkFile="MTVehicles.jar"
        integrityProtect
        versionCompare
        update MTVehicles.jar
        clean
    fi

    if [[ $@ =~ "geyser" ]]; then
        export isPlugin=true
        pluginUpdate Geyser
        export checkFile='Geyser-Spigot.jar'
        integrityProtect
        versionCompare
        update *.jar
        clean
    fi

    if [[ $@ =~ "floodgate" ]]; then
        export isPlugin=true
        export checkFile='floodgate-spigot.jar'
        pluginUpdate Floodgate
        integrityProtect
        versionCompare
        update *.jar
        clean
    fi

    if [[ $@ =~ "sac" ]]; then
        echo "Warning! Beta support for SoaromaSAC"
        isPlugin=true
        unset checkFile
        update *.jar
    fi
    ######Plugin Update End######

    systemUpdate
    rm -rf ${serverPath}/plugins/BuildTools.jar
    clean
    echo "Job finished at `date`, have a nice day~"
    exit 0
}

######Function End######
if [[ $@ =~ "outtolog" ]]; then
    main $@ 1>> updater.log 2>>debug.log
else
    main $@
fi
