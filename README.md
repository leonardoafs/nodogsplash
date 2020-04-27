## 0. Documentação Hotspot Wifi + Captive Portal

Este README visa auxiliar na instalação de um Hotspot Wi-Fi com um captive portal configurável.
Primeiramente vamos configurar um hotspot wifi. Depois, vamos instalar o captive portal.

Github original: https://github.com/nodogsplash/nodogsplash

### Pré-Requisitos
 * **Raspberry Pi 3B ou 3B+**.
 * **Conexão com a internet via cabo Ethernet**.
 * **Teclado e Mouse, ou acesso à mesma rede para acesso via SSH**.


## 1. Configurando um Hotspot Wifi

Primeiramente, vamos atualizar os repositórios do sistema:

```
sudo apt-get update
sudo apt-get upgrade
```

Com isso, vamos instalar dois pacotes essenciais, `hostapd` e `dnsmasq`, bem como o editor `vim`:

`sudo apt-get install hostapd dnsmasq vim`

Após, vamos pausar esses serviços:

```
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```

Agora, vamos configurar o arquivo dhcpd.conf:

`sudo vim /etc/dhcpcd.conf`

No fim do arquivo, vamos adicionar o seguinte:

```
interface wlan0
    static ip_address=192.168.220.1/24
    nohook wpa_supplicant
```

Com isso, fechamos o arquivo.
Agora, vamos reiniciar o serviço `dhcpcd` para validar as mudanças.

``` 
sudo systemctl restart dhcpcd
```

Vamos abrir o arquivo `hostapd.conf`

``` 
sudo vim /etc/hostapd/hostapd.conf
```

Nesse arquivo vamos mudar as linhas para a configuração que desejamos. Basta apagar o `<NOME DA SUA REDE WI-FI>` e `<SENHA DA REDE WI-FI>` para o que você desejar:

```
ssid=<NOME DA SUA REDE WI-FI>

wpa_passphrase=<SENHA DA REDE WI-FI>
```

Aperte `:x` para salvar e sair.
Vamos configurar o caminho de nosso hostapd.

```
sudo vim /etc/default/hostapd
```

Nesse arquivo, devemos trocar `#DAEMON_CONF="" ` por `DAEMON_CONF="/etc/hostapd/hostapd.conf"`.
Agora salvamos usando `:x`.


Devemos fazer parecido em outro arquivo:
```
sudo vim /etc/init.d/hostapd
```
Agora, devemos trocar `DAEMON_CONF= ` por `DAEMON_CONF=/etc/hostapd/hostapd.conf`.
Salvamos usando `:x`.

Com isso, configurando o `dnsmasq`, modificaremos o arquivo de configuração.
Primeiramente, moveremos o arquivo original para um backup, para que possamos criar um novo.
```
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
```

Agora, podemos criar nosso arquivo de configuração:
```
sudo vim /etc/dnsmasq.conf
```
Adicionaremos o texto abaixo:
```
interface=wlan0       # Use interface wlan0  
server=1.1.1.1       # Use Cloudflare DNS  
dhcp-range=192.168.220.50,192.168.220.150,12h # IP range and lease time
```

Agora, vamos configurar para que o tráfego seja redirecionado para quem for se conectar:
```
sudo vim /etc/sysctl.conf
```
Onde temos `#net.ipv4.ip_forward=1`, devemos mudar para `net.ipv4.ip_forward=1`.

Para ter as configurações rodando a partir de agora, devemos digitar `sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"`

Agora, para carregar as novas regras de iptables, digitamos `sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`

Para que as regras sejam carregadas em todo novo boot do sistema, digitamos `sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"`

Agora, abriremos o arquivo `rc.local`:
`sudo vim /etc/rc.local`
No final dele, colocaremos uma nova linha, logo acima de `exit 0`:
```
iptables-restore < /etc/iptables.ipv4.nat
```

Agora salvamos com `:x`.

Reiniciando os serviços que tinhamos pausado antes:
```
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo service dnsmasq start
```

Agora, reiniciaremos com `sudo reboot`.
Com isso, temos um Ponto de Acesso configurado, porém ainda sem o Captive Portal, o que nos leva para a segunda parte.

## 2. Instalando o Captive Portal


**Nodogsplash** (NDS) is a high performance, small footprint Captive Portal, offering by default a simple splash page restricted Internet connection, yet incorporates an API that allows the creation of sophisticated authentication applications.

**Captive Portal Detection (CPD)**

 All modern mobile devices, most desktop operating systems and most browsers now have a CPD process that automatically issues a port 80 request on connection to a network. NDS detects this and serves a special "**splash**" web page to the connecting client device.

**Provide simple and immediate public Internet access**

 NDS provides two pre-installed methods.

 * **Click to Continue**. A simple static web page with template variables (*default*). This provides basic notification and a simple click/tap to continue button.
 * **Username/email-address login**. A simple dynamic set of web pages that provide username/email-address login, a welcome page and logs access by client users. (*Installed by default and enabled by un-commenting a line in the configuration file*)

Customising the page seen by users is a simple matter of editing the respective html or script files.

**Write Your Own Captive Portal.**

 NDS can be used as the "Engine" behind the most sophisticated Captive Portal systems using the tools provided.

 * **Forward Authentication Service (FAS)**. FAS provides pre-authentication user validation in the form of a set of dynamic web pages, typically served by a web service independent of NDS, located remotely on the Internet, on the local area network or on the NDS router.
 * **PreAuth**. A special case of FAS that runs locally on the NDS router with dynamic html served by NDS itself. This requires none of the overheads of a full FAS implementation and is ideal for NDS routers with limited RAM and Flash memory.
 * **BinAuth**. A method of running a post authentication script or extension program.


## 2. Documentation

For full documentation please look at https://nodogsplashdocs.rtfd.io/

You can select either *Stable* or *Latest* documentation.

---

Email contact: nodogsplash (at) ml.ninux.org
