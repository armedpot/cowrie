# Honeypot Cowrie

Cowrie is a medium interactive SSH & Telnet honeypot. Cowrie was developed by Michel Oosthof based on Kippo and published on Github. Besides an SSH login, the honeypot also emulates a filesystem as well as over 50 different operating system commands like wget, curl, top, ls, df, dmesg, mount, sync, yum, apt, cat dd and more. It is also possible for an attacker to download switching code/tools via wget, which is then made available virtually on the operating system. The downloads are also saved and can be evaluated. The attackers' sessions are recorded and can be played back using a player.

# Installation

The Docker container uses the user cowrie with the user ID 2000 and the group ID 2000 . For the container to write its logs on the host system, a user with UserID 2000 and GroupID 2000 must also exist here or be created beforehand.

```bash
user:~$ sudo groupadd --gid 2000 armedpot
user:~$ sudo useradd --gid 2000 --uid 2000 --create-home --password '*' --shell /bin/bash armedpot
user:~$ sudo usermod -aG docker armedpot
user:~$ sudo su - armedpot
armedpot:~$ git clone https://github.com/armedpot/cowrie.git
armedpot:~$ mkdir -p ~/data/cowrie/data/{downloads,keys,tty,snapshots} ~/data/cowrie/log
armedpot:~$ cd cowrie
armedpot:~$ [[ ! -f ~/data/cowrie/log/cowrie.db ]] && cp dist/cowrie.db ~/data/cowrie/log/cowrie.db
```

Once the user and group have been created with ID 2000 each, the Github repository has been cloned, the required directories have been created, the cowrie directory has been created, and the sqlite3 cowrie.db has been copied to the directory if it does not exist, cowrie can be started via Docker compose as follows:

```bash
armedpot:~/cowrie$ docker-compose up -d
```

## .env

in the .env file the version of the Dockerization can be determined.

## Docker

Alternatively, the container can be started without docker-compose using the following Docker command:

```bash
armedpot:~/cowrie$ docker run \
    --detach \
    --name cowrie \
    --publish 22:2222 \
    --publish 23:2223 \
    --tmpfs /home/cowrie/cowrie-git/var/run:uid=2000,gid=2000 \
    --volume ~/data/cowrie/data:/home/cowrie/cowrie-git/var/lib/cowrie \
    --volume ~/data/cowrie/log:/home/cowrie/cowrie-git/var/log/cowrie \
    --read-only \
    --rm \
    armedpot/cowrie:latest
```

# Links

- Honeypot [cowrie](https://github.com/cowrie/cowrie) on Github
- [Armedpot](https://hub.docker.com/repository/docker/armedpot/cowrie) on Dockerhub for x86/arm/arm64
- [Awesome Honeypots](https://github.com/paralax/awesome-honeypots) on Github
- Deutsche Telekom Security [Tpot](https://github.com/telekom-security/tpotce)
