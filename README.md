## 0. Documentação Hotspot Wifi + Captive Portal

Este README visa auxiliar na instalação de um Hotspot Wi-Fi com um captive portal configurável.
Primeiramente vamos configurar um hotspot wifi. Depois, vamos instalar o captive portal.

Github original: https://github.com/nodogsplash/nodogsplash

### Pré-Requisitos
 * **Raspberry Pi 3B ou 3B+**.
 * **Conexão com a internet via cabo Ethernet**.
 * **Teclado e Mouse, ou acesso à mesma rede para acesso via SSH**.


## 1. Configurando um Hotspot Wifi

1) Primeiramente, vamos atualizar os repositórios do sistema:

```
sudo apt-get update
sudo apt-get upgrade
```

2) Com isso, vamos instalar dois pacotes essenciais, `hostapd` e `dnsmasq`, bem como o editor `vim`:

`sudo apt-get install hostapd dnsmasq vim`

3) Após, vamos pausar esses serviços:

```
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```

4) Agora, vamos configurar o arquivo dhcpd.conf:

`sudo vim /etc/dhcpcd.conf`

No fim do arquivo, vamos adicionar o seguinte:

```
interface wlan0
    static ip_address=192.168.220.1/24
    nohook wpa_supplicant
```

Com isso, fechamos o arquivo.

5) Agora, vamos reiniciar o serviço `dhcpcd` para validar as mudanças.

``` 
sudo systemctl restart dhcpcd
```

6) Vamos abrir o arquivo `hostapd.conf`

``` 
sudo vim /etc/hostapd/hostapd.conf
```

Nesse arquivo vamos mudar as linhas para a configuração que desejamos. Basta apagar o `<NOME DA SUA REDE WI-FI>` e `<SENHA DA REDE WI-FI>` para o que você desejar:

```
ssid=<NOME DA SUA REDE WI-FI>

wpa_passphrase=<SENHA DA REDE WI-FI>
```

Aperte `:x` para salvar e sair.

7) Vamos configurar o caminho de nosso hostapd.

```
sudo vim /etc/default/hostapd
```

Nesse arquivo, devemos trocar `#DAEMON_CONF="" ` por `DAEMON_CONF="/etc/hostapd/hostapd.conf"`.
Agora salvamos usando `:x`.


8) Devemos fazer parecido em outro arquivo:
```
sudo vim /etc/init.d/hostapd
```
Agora, devemos trocar `DAEMON_CONF= ` por `DAEMON_CONF=/etc/hostapd/hostapd.conf`.
Salvamos usando `:x`.

9) Com isso, configurando o `dnsmasq`, modificaremos o arquivo de configuração.
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

10) Agora, vamos configurar para que o tráfego seja redirecionado para quem for se conectar:
```
sudo vim /etc/sysctl.conf
```
Onde temos `#net.ipv4.ip_forward=1`, devemos mudar para `net.ipv4.ip_forward=1`.

11) Para ter as configurações rodando a partir de agora, devemos digitar `sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"`

12) Agora, para carregar as novas regras de iptables, digitamos `sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`

13) Para que as regras sejam carregadas em todo novo boot do sistema, digitamos `sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"`

14) Agora, abriremos o arquivo `rc.local`:
`sudo vim /etc/rc.local`
No final dele, colocaremos uma nova linha, logo acima de `exit 0`:
```
iptables-restore < /etc/iptables.ipv4.nat
```

Agora salvamos com `:x`.

15) Reiniciando os serviços que tinhamos pausado antes:
```
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo service dnsmasq start
```

16) Agora, reiniciaremos com `sudo reboot`.
Com isso, temos um Ponto de Acesso configurado, porém ainda sem o Captive Portal, o que nos leva para a segunda parte.

## 2. Instalando o Captive Portal

17) Primeiramente, instalaremos o `git` e o `libmicrohttpd-dev`:
```
sudo apt install git libmicrohttpd-dev
```

18) Agora, clonaremos esse repositório:
```
cd
git clone https://github.com/leonardoafs/nodogsplash.git
```

19) Agora, compilaremos e instalaremos a ferramenta:
```
cd /nodogsplash
sudo make
sudo make install
```

20) Agora, poderemos alterar algumas coisas no arquivo de configuração. Devemos abrir:
```
sudo vim /etc/nodogsplash/nodogsplash.conf
```

21) Agora, devemos achar essas linhas abaixo e fazer as alterações para que elas fiquem exatamente como abaixo:
```
GatewayInterface wlan0
GatewayAddress 192.168.220.1
MaxClients 250
AuthIdleTimeout 480
use_outdated_mhd 1
login_option_enabled 1
```
Salvamos e fechamos usando `:x`.

22) Com isso, podemos iniciar o programa:
```
sudo nodogsplash
```
Neste momento, podemos testar o funcionamento do Captive Portal. Aos nos conectarmos à rede utilizando a senha configurada, o dispositivo que você estiver usando deve abrir um Captive Portal, requisitando nome e email, que serão guardados em um arquivo de log, para liberar acesso à internet. Ao fazer isso, devemos receber uma mensagem de "Success".

23) Agora, abriremos o arquivo `rc.local`:
`sudo vim /etc/rc.local`
No final dele, colocaremos uma nova linha, logo acima de `exit 0`:
```
nodogsplash
```
