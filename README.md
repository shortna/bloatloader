# simple boot loader
written for i386 architecture
uses dos interupts 
assumed img foramt is - raw

build:
```
make          # making binary
make qemu-img # making raw img for qemu vm
make qemu     # run vm with img 
```

clean:
```
make clean
```


