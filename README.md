## O que é o inSANE?

https://youtu.be/2RC3N_SRmq0

O inSANE é um script simples que utiliza o SANE para escanear imagens. Por padrão, ele escaneia as imagens para a pasta `~/Imagens/Scan` com uma resolução de 600 DPI, mas ele pode ser configurado com um arquivo `.insane.conf` que fica localizado na pasta `/home` do usuário. E esse arquivo tem a seguinte estrutura:

```
Pasta=~/Imagens/Escaneados
Resolucao=300
```

## Por que fazer esse Script?
Esse Script surgiu de uma necessidade minha: O Epson Scan 2 e o Gnome Simple Scan pararam de funcionar, e eu não estava nem um pouco afim de reinstalar o sistema. Com isso descobri uma forma de escanear por linha de comando e assim construí esse Script.

## Em que Scanner ele funciona?
Por enquanto ele apenas funciona em Scanners da Epson. Não sei a compatilidade dele com Scanners de outras marcas. Mas acredito que funcione.

Até onde testei, o inSANE funciona apenas com Scanners conectados via USB. Não consegui testar com nada via Rede.

## Problemas conhecidos
- Um bug que me deparei com esse código é que às vezes o scanimage -L não consegue detectar o scanner. A solução pra isso é desconectar e conectar o cabo USB do Scanner.
