# aceph
 ceph Стенд


git clone https://github.com/vanitoo/aceph.git && cd ./aceph/ubuntu20.04-virsh && sudo chmod u+x *.sh



запускаем на DELL тестовый стенд  (машинка должна быть настроена под KVM)

запускаем 1   - создает 4 хоста - аналог титана

запускаем 2   - настраивает виртуализацию на этих хостах

запускаем 3   - создает по 4 ВМ на каждом хосту, итого 16

запускаем 4   - русификация, ансибль, время, настройки хост

запускаем 4.1 - меняет размер диска на ВМках с 6 до 20гб

запускаем 5   - ставится ЦЕФ админ и все компоненты на всех ВМках

запускаем 6   - настройка кластера



mons - мониторинг
osds - демон хранения
mgrs - менеджер
mds - сервер метаданных



https://itc-life.ru/deploy-ceph-via-cephadm-on-ubuntu-20-04-on-3-nodes/
https://bogachev.biz/2017/08/23/zametki-administratora-ceph-chast-1/
https://docs.oracle.com/en/operating-systems/oracle-linux/ceph-storage/ceph-luminous-using.html#ceph-luminous-block-setup

