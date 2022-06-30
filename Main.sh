#!/bin/bash

######Function Start######
#Clean leftovers
function cleanFile(){
    if [[ $@ =~ 'buildTools' ]]; then
        for trash in 'apache-maven-3.6.0' 'BuildData' 'Bukkit' 'CraftBukkit' 'Spigot' 'work'; do
            rm -fr ${trash} 1>/dev/null 2>/dev/null
        done
    unset trash
    fi
    if [[ $@ =~ 'log' ]]; then
        for logFiles in 'debug.log' 'BuildTools.log.txt' 'wget-log' 'updater.log'; do
            rm -f ${logFiles}
        done
        unset logFiles
    fi
}

#Exit script
function exitScript(){
    if [ $@ = 0 ]; then
    exit $@
    else
        echo '[Critical] exit code detected!'
        echo "Exit code: $@ "
        echo '[Critical] You may follow the instructions to debug'
        if [[ $@ =~ 1 ]]; then
            sign='Unknown error'
        elif [[ $@ =~ 2 ]]; then
            sign='Can not create directory'
        elif [[ $@ =~ 3 ]]; then
            sign='Non-64-bit system detected'
        elif [[ $@ =~ 4 ]];then
            sign='Environment variables not set'
        elif [[ $@ =~ 5 ]]; then
            sign='System update failed.'
        else
            sign="Undefined error code"
        fi
        echo "[Critical] ${sign}"
        echo '[Critical] Exitting...'
        unset ${sign}
        exit $@
    fi
}

#Create folders for the first time
function createFolder(){
    if [ ! -d ${serverPath} ]; then
        echo '[Info] Path to server is empty, creating new directory'
        mkdir ${serverPath}
        mkdir ${serverPath}/plugins
        if [ $? = 1 ]; then
        echo '[Info] mkdir returned error code 1, retrying with sudo'
            if [ $@ =~ 'unattended' ]; then
                echo '[Warn] unattended flag detected.'
                exitScript 2
            else
                if [ `whoami` = root ]; then
                    exitScript 2
                else
                    sudo mkdir ${serverPath}
                    sudo mkdir ${serverPath}/plugins
                fi
            fi
        fi
        echo '[Info] Directory created.'
    else
        echo '[Info] Directory already exists'
    fi
    if [ ! -d ${serverPath}/plugins ]; then
        echo '[Info] Plugins folder not found, trying to create'
        mkdir ${serverPath}/plugins
        if [ $? = 1 ]; then
            echo '[Info] mkdir failed, trying with root'
            if [[ $@ =~ 'unattended' ]]; then
                sudo mkdir ${serverPath}/plugins
            else
                echo '[Warn] unattended flag detected'
                exitScript 2
            fi
            if [ $? = 1 ]; then
                echo '[Warn] Plugins folder cannot be created'
                exitScript 2
            fi
        fi
    else
        echo '[Info] Directory already exists'
    fi
}

#Build origin server
function buildMojang(){
    if [ ${version} = 1.19 ]; then
        url=https://launcher.mojang.com/v1/objects/e00c4052dac1d59a1188b2aa9d5a87113aaf1122/server.jar
    fi
    wget https://launcher.mojang.com/v1/objects/e00c4052dac1d59a1188b2aa9d5a87113aaf1122/server.jar >/dev/null 2>/dev/null

}

#Build Spigot
function buildSpigot(){
    url="https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
    checkFile=BuildTools.jar
    echo "[Info] Downloading BuildTools for Spigot..."
    wget ${url} >/dev/null 2>/dev/null
    java -jar $checkFile nogui --rev ${version} >/dev/null 2>/dev/null
    rm -rf ${checkConfig}
    mv spigot-*.jar Spigot-latest.jar
    update Spigot-latest.jar
}

#testPackageManager
function detectPackageManager(){
    echo "[Info] Detecting package manager..."
    if [[ $@ =~ 'nosudo' ]]; then
        if [[ $(apt install ) ]]; then
            echo '[Info] Detected apt'
            packageManager=apt
        elif [[ $(pacman -h ) ]]; then
            echo '[Info] Detected pacman'
            packageManager=pacman
        elif [[ $(dnf install ) ]]; then
            echo '[Info] Detected dnf'
            packageManager=dnf
        else
            packageManager=unknown
        fi
    else
        if [[ $(sudo apt install ) ]]; then
            echo '[Info] Detected apt'
            packageManager=apt
        elif [[ $(sudo pacman -h ) ]]; then
            echo '[Info] Detected pacman'
            packageManager=pacman
        elif [[ $(sudo dnf install ) ]]; then
            echo '[Info] Detected dnf'
            packageManager=dnf
        else
            packageManager=unknown
        fi
    fi
}
#checkConfig
checkConfig(){
    if [ ! ${version} ]; then
        exitScript 4
    fi
    if [ ! ${serverPath} ]; then
        exitScript 4
    fi
    if [ ! $build ]; then
        export build=500
    fi
}
#removeJarFile
function clean(){
    echo "[Info] Cleaning."
    rm -rf *.jar
    rm -rf *.check
    rm -rf *.1
    rm -rf *.2
}
#moveFile
function update(){
    echo "[Info] Updating jar file..."
    if [[ $@ = "Paper-latest.jar" ]]; then
        mv $@ ${serverPath}
    elif [[ $@ = "Spigot-latest.jar" ]]; then
        mv $@ ${serverPath}/$@
    else
        mv $@ ${serverPath}/plugins/
    fi
}
#versionCompare
function versionCompare(){
    echo "[Info] Making sure you're up to date."
    if [ $isPlugin = true ]; then
        checkPath="${serverPath}/plugins"
    else
        checkPath="${serverPath}"
    fi
    diff -q "${checkPath}/${checkFile}" "${checkFile}" >/dev/null 2>/dev/null
    return $?
}
#integrityProtect
function integrityProtect(){
    echo "[Info] Checking file integrity."
    if [[ $@ =~ "unsafe" ]]; then
        echo "[Warn] Default protection disabled. USE AT YOUR OWN RISK!"
        return 0
    else
        echo "[Info] Verifing ${checkFile}"
        if [ ${isPlugin} = false ]; then
            checkFile=Paper-latest.jar
            wget $url >/dev/null 2>/dev/null
            mv paper-*.jar Paper-latest.jar.check
            diff -q Paper-latest.jar.check Paper-latest.jar >/dev/null 2>/dev/null
            return $?
        else
            mv $checkFile "${checkFile}.check"
            wget $url >/dev/null 2>/dev/null
            diff -q $checkFile "${checkFile}.check" >/dev/null 2>/dev/null
            return $?
        fi
    fi
    if [ $? = 1 ]; then
        echo "[Warn] Checking job done, repairing ${checkFile}."
        redownload
    else
        echo "[Info] Ckecking job done, ${ckeckFile} verified."
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
    echo "[Info] Updating ${checkFile}"
    if [ $@ = Floodgate ]; then
        pluginName="$@"
        url="https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar"
    elif [ $@ = Geyser ]; then
        pluginName="$@"
        url="https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar"
    elif [ $@ = SAC ]; then
        pluginName="$@"
        url="https://www.spigotmc.org/resources/soaromasac-lightweight-cheat-detection-system.87702/download?version=455200"
    elif [ $@ = MTVehicles ]; then
        pluginName="$@"
        url="https://www.spigotmc.org/resources/mtvehicles-vehicle-plugin-free-downloadable.80910/download?version=452759"
    else
        echo "[Warn] Sorry, but we don't have your plugin's download url. Please wait for support~"
    fi
    echo "[Info] Downloading ${pluginName}"
    wget $url >/dev/null 2>/dev/null
    isPlugin=true
}
#systemUpdate
function systemUpdate(){
    if [[ $@ =~ 'nosudo' ]]; then
        if [ ${packageManager} = apt ]; then
            echo "[Info] Updating using apt..."
            apt -y full-upgrade
        elif [ ${packageManager} = dnf ]; then
            echo "[Info] Updating using dnf..."
            dnf -y update
        elif [ ${packageManager} = pacman ]; then
            echo "[Info] Updating using pacman..."
            pacman --noconfirm -Syyu
        else
            unset packageManager
            echo "[Critical] Package manager not found!"
            exitScript 5
        fi
    else
        if [ ${packageManager} = apt ]; then
            echo "[Info] Updating using apt..."
            sudo apt -y full-upgrade
        elif [ ${packageManager} = dnf ]; then
            echo "[Info] Updating using dnf..."
            sudo dnf -y update
        elif [ ${packageManager} = pacman ]; then
            echo "[Info] Updating using pacman..."
            sudo pacman --noconfirm -Syyu
        else
            unset packageManager
            exitScript 5
        fi
    fi
}

#buildPaper
function buildPaper(){
    while [ ! -f paper-*.jar ]; do
        export build=`expr ${build} - 1`
        echo "[Info] Testing build ${build}"
        url="https://papermc.io/api/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar"
        wget $url >/dev/null 2>/dev/null
    done
    echo "[Info] Downloaded build ${build}."
    if [ -f paper-*.jar ]; then
        mv paper-*.jar Paper-latest.jar
    fi
    export isPlugin=false
    export checkFile=Paper-latest.jar
    integrityProtect
    versionCompare
    if [ $? = 0 ]; then
        echo "[Info] You're up to date."
        clean
    else
        echo "[Info] Updating Paper..."
        update Paper-latest.jar
    fi
    clean
}

#32-bit Warning
function checkBit(){
    getconf LONG_BIT
    return $?
    if [ $? = 64 ]; then
        echo "[Info] Running on 64-bit system."
    elif [ $? = 32 ]; then
        if [[ $@ =~ "unsafe" ]]; then
            echo "[Warn] Warning at `date`, running on 32-bit system may encounter unexpected problems."
        else
            exitScript 3
        fi
    fi
}

function updateMain(){
    echo "[Info] Hello! `whoami` at `date`"
    checkBit
    echo "[Info] Reading settings"
    clean
    checkConfig
    if [[ $@ =~ 'newserver' ]]; then
        createFolder $@
    fi

    ######Paper Update Start######
    echo "[Info] Starting auto update at `date`"
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
        echo "[Warn] Warning! Beta support for SoaromaSAC"
        isPlugin=true
        unset checkFile
        update *.jar
    fi


    if [[ $@ =~ 'clean' ]]; then
        cleanFile -buildTools
        cleanFile -logFiles
    fi
    ######Plugin Update End######
    detectPackageManager $@
    systemUpdate $@
    rm -rf ${serverPath}/plugins/BuildTools.jar #Due to a unknown bug
    clean
    echo "[Info] Job finished at `date`, have a nice day~"
    exitScript 0
}

######Function End######
if [[ $@ =~ update ]]; then
    if [[ $@ =~ "unattended" ]]; then
        updateMain $@ 1>> updater.log 2>>debug.log
    else
        updateMain $@
    fi
fi