#!/bin/bash
######User Settings Start######
export version=1.19
export serverPath=/mnt/main/Cache/Paper
######User Settings End######

######Function Start######
#Build Spigot
function buildSpigot(){
    url=https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
    checkFile=BuildTools.jar
    wget ${url}
    isPlugin=true
    integrityProtect
    java -jar $checkFile nogui --rev ${version}
    mv spigot-*.jar Spigot-latest.jar
    update Spigot-latest.jar
    rm -rf ${serverPath}/plugins/BuildTools.jar
}

#testPackageManager
function detectPackageManager(){
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
        echo '$version not set, please enter your desied version'
        read version
    fi
    if [ ! ${serverPath} ]; then
        echo "Warning! serverPath not set, please enter complete path to your server"
        read serverPath
    fi
    if [ ! $build ]; then
        export build=500
    fi
}
#removeJarFile
function clean(){
    rm -rf *.jar
    rm -rf *.check
    rm -rf *.1
    rm -rf *.2
}
#moveFile
function update(){
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
    if [[ $@ =~ "nocheck" ]]; then
        echo "Warning! Default protection disabled. USE AT YOUR OWN RISK!"
        return 0
    else
        echo "Verifing ${checkFile}"
        if [ ${isPlugin} = false ]; then
            checkFile=Paper-latest.jar
            wget $url
            mv paper-*.jar Paper-latest.jar.check
            diff -q Paper-latest.jar.check Paper-latest.jar
            return $?
        else
            mv $checkFile "${checkFile}.check"
            wget $url
            diff -q $checkFile "${checkFile}.check"
            return $?
        fi
    fi
    if [ $? = 1 ]; then
        echo "Checking job done, repairing ${checkFile}."
        redownload
    else
        echo "Ckecking job done, ${ckeckFile} verified."
        rm -rf *.check
    fi
}
function redownload(){
    clean
    if [ ${isPlugin} = false ]; then
        checkFile=Paper-latest.jar
        wget $url
        mv paper-*.jar Paper-latest.jar
        integrityProtect
    else
        wget $url
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
    else
        echo "Sorry, but we don't have your plugin's download url. Please wait for support~"
    fi

    wget $url
    export isPlugin=true
    #export checkFile="${pluginName}"
}
#systemUpdate
function systemUpdate(){
    if [ `whoami` = root ]; then
        detectPackageManager
        if [[ $@ =~ "systemupdate" ]]; then
            if [ $? = apt ]; then
                apt -y full-upgrade
            elif [ $? = dnf ]; then
                dnf -y dnf update
            elif [ $? = pacman ]; then
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
        fi
    else
        echo "System Update Failed! You are running under `whoami`"
    fi
}

#buildPaper
function buildPaper(){
    while [ ! -f paper-*.jar ]; do
        export build=`expr ${build} - 1`
        echo "Testing build ${build}"
        url="https://papermc.io/api/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar"
        wget $url
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
        rm Paper-latest.jar
    else
        update Paper-latest.jar
    fi
    clean
}
######Function End######

echo "Hello! `whoami` at `date`"
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

######System Update Start######

######System Update End######
echo "Notice: Script will try to do a full system update"
systemUpdate
######Clean Environment Variables Start######
unset version
unset serverPath
unset checkPath
unset isPlugin
unset packageManager
unset checkFile
rm -rf ${serverPath}/plugins/BuildTools.jar
clean
######Clean Environment Variables End######
echo "Job finished at `date`, have a nice day~"
exit 0
