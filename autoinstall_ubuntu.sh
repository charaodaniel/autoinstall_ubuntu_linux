#!/bin/bash
# cria pasta temporária e define limpeza
tmp="$(mktemp -d -t autoinstallXXXXX)"
cd "$tmp" || exit 2

# limpeza
cleanup() {
    rm -rf "$tmp"
}
trap cleanup EXIT

## VARS
# variáveis do pacote
BASEAPT="sudo apt-get update && sudo apt-get install -y chromium-browser libreoffice pinta wine64 wine64-development wine32-development libwine-dev flatpak v4l2loopback-dkms v4l2loopback-utils v4l-utils pipewire-bin"
BASEFLAT="flatpak install -y --noninteractive --or-update com.github.IsmaelMartinez.teams_for_linux"
BASEPPA="sudo add-apt-repository -y ppa:appimagelauncher-team/stable && sudo apt-get update && sudo apt-get install -y appimagelauncher"
GAMEAPT="sudo apt-get update && sudo apt-get install -y timeshift libvkd3d1 libvkd3d1:i386 gamemode libgamemode0 libgamemode0:i386 wine64 wine64-development wine32-development libwine-dev flatpak v4l2loopback-dkms v4l2loopback-utils v4l-utils pipewire-bin mangohud gamescope goverlay"
GAMEFLAT="flatpak install -y --noninteractive --or-update net.lutris.Lutris org.prismlauncher.PrismLauncher com.valvesoftware.Steam com.heroicgameslauncher.hgl io.github.unknownskl.greenlight com.discordapp.Discord com.valvesoftware.Steam.VulkanLayer.MangoHud org.freedesktop.Platform.VulkanLayer.MangoHud com.valvesoftware.Steam.Utility.MangoHud com.obsproject.Studio"

## FUNÇÕES
# obter idioma do sistema operacional
get_lang() {
    local lang="${LANG:0:2}"
    local available=("pt" "en")

    if [[ " ${available[*]} " == *"$lang"* ]]; then
        ulang="$lang"
    else
        ulang="en"
    fi
}

languages() {
    if [ "$ulang" == "pt" ]; then
        intro() {
            echo "Este é o script *Psygreg AutoInstall*."
            echo "Ele atualiza completamente o sistema, instala todos os aplicativos, drivers e dependências necessárias para seu sistema Linux baseado em Ubuntu."
            echo "Se todos os programas já tiverem sido instalados, ele só irá fazer uma atualização completa do sistema e criará um ponto de restauração quando finalizar."
        }
        bundleopt="Qual pacote deseja instalar?"
        cancel="Operação cancelada."
        success="Script Psygreg AutoInstall concluiu com sucesso. Reinicie para aplicar as alterações."
        radeoncheck="Patch Radeon-Vulkan já aplicado ou não é necessário, pulando..."
        noroot="Não execute o AutoInstall como root."
        ubuntu="APT encontrado, iniciando..."
        nubuntu="APT não encontrado. Você está usando uma distribuição baseada em Ubuntu?"
        ppa_check="PPA já instalado, prosseguindo..."
    else
        intro() {
            echo "This is the *Psygreg AutoInstall Script*."
            echo "It will perform a complete system update, and install required dependencies, drivers and applications to your Ubuntu-based Linux system."
            echo "If all programs are already installed, it will just perform the system update and create a system restore point through Timeshift."
        }
        bundleopt="Which bundle do you wish to install?"
        cancel="Operation cancelled."
        success="Script Psygreg AutoInstall has finished successfully. Reboot to apply all changes."
        radeoncheck="Radeon Vulkan fix already applied or unnecessary, skipping..."
        noroot="Do not run AutoInstall as root."
        ubuntu="APT found. Starting..."
        nubuntu="APT not found. Are you using an Ubuntu-based distro?"
        ppa_check="PPA already installed, proceeding..."
    fi
}

# escolha do pacote
choose_bundle() {
    echo "1) Basic"
    echo "2) Gamer"
    echo "3) Cancelar"
    read -p "(1, 2 ou 3): " bundle
}

# ponto de restauração failsafe
restore() {
    sudo apt-get update && sudo apt-get install -y timeshift
    sudo timeshift --create --comments "Autoinstall Backup" --tags M
}

# patch radeon vulkan
radeon_vlk() {
    if dpkg -l | grep -q "amdvlk"; then
        sudo apt-get remove -y amdvlk
        sudo apt-get install -y mesa-vulkan-drivers mesa-vulkan-drivers:i386
    else
        echo "$radeoncheck"
    fi
}

# instalação do flatpak
install_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        if lsb_release -cs | grep -q 'bionic\|xenial'; then
            sudo add-apt-repository ppa:flatpak/stable
            sudo apt-get update
            sudo apt-get install -y flatpak
        else
            sudo apt-get install -y flatpak
        fi
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        sudo apt-get install -y gnome-software-plugin-flatpak
    fi
}

## INÍCIO DA EXECUÇÃO DO SCRIPT
# obter idioma
get_lang
languages

# verificação de root
if (( ! UID )); then
    echo "$noroot"
    exit 1
else
    # verificar se o sistema operacional é baseado em ubuntu procurando por apt
    if command -v apt-get &> /dev/null; then
        echo "$ubuntu"
    else
        echo "$nubuntu"
        exit 2
    fi
    intro
    install_flatpak
    ## RADEON FIX
    radeon_vlk
    ## INSTALAÇÃO DO PACOTE
    echo "$bundleopt"
    choose_bundle
    if [ "$bundle" == "1" ]; then
        restore
        eval "$BASEAPT"
        eval "$BASEFLAT"
        eval "$BASEPPA"
    elif [ "$bundle" == "2" ]; then
        restore
        eval "$GAMEAPT"
        eval "$GAMEFLAT"
        eval "$BASEPPA"
    else
        echo "$cancel"
        exit 0
    fi
    echo "$success"
    exit 0
fi
