/*2:*/
#line 54 "base64.w"

#include "config.h"                   

#define REVDATE "10th June 2007" \

#define TRUE 1
#define FALSE 0
#define LINELEN 72
#define MAXINLINE 256 \


#line 57 "base64.w"


/*3:*/
#line 68 "base64.w"

#include <stdio.h> 
#include <stdlib.h> 
#include <ctype.h> 
#ifdef HAVE_STRING_H
#include <string.h> 
#else
#ifdef HAVE_STRINGS_H
#include <strings.h> 
#endif
#endif
#ifdef HAVE_GETOPT
#ifdef HAVE_UNISTD_H
#include <unistd.h> 
#endif
#else
#include "getopt.h"     
#endif

/*:3*/
#line 59 "base64.w"

/*4:*/
#line 90 "base64.w"

#ifdef _WIN32
#define FORCE_BINARY_IO
#include <io.h> 
#include <fcntl.h> 
#endif

/*:4*/
#line 60 "base64.w"

/*5:*/
#line 101 "base64.w"

typedef unsigned char byte;

static FILE*fi;
static FILE*fo;
static byte iobuf[MAXINLINE];
static int iolen= 0;
static int iocp= MAXINLINE;
static int ateof= FALSE;
static byte dtable[256];
static int linelength= 0;
static char eol[]= 
#ifdef FORCE_BINARY_IO
"\n"
#else
"\r\n"
#endif
;
static int errcheck= TRUE;

/*:5*/
#line 61 "base64.w"


/*:2*//*7:*/
#line 126 "base64.w"


static int inbuf(void)
{
int l;

if(ateof){
return FALSE;
}
l= fread(iobuf,1,MAXINLINE,fi);
if(l<=0){
if(ferror(fi)){
exit(1);
}
ateof= TRUE;
return FALSE;
}
iolen= l;
iocp= 0;
return TRUE;
}

/*:7*//*8:*/
#line 153 "base64.w"


static int inchar(void)
{
if(iocp>=iolen){
if(!inbuf()){
return EOF;
}
}

return iobuf[iocp++];
}

/*:8*//*9:*/
#line 172 "base64.w"


static int insig(void)
{
int c;

while(TRUE){
c= inchar();
if(c==EOF||(c> ' ')){
return c;
}
}
}

/*:9*//*10:*/
#line 191 "base64.w"


static void ochar(int c)
{
if(linelength>=LINELEN){
if(fputs(eol,fo)==EOF){
exit(1);
}
linelength= 0;
}
if(putc(((byte)c),fo)==EOF){
exit(1);
}
linelength++;
}

/*:10*//*11:*/
#line 213 "base64.w"


static void encode(void)
{
int i,hiteof= FALSE;

/*12:*/
#line 275 "base64.w"


for(i= 0;i<9;i++){
dtable[i]= 'A'+i;
dtable[i+9]= 'J'+i;
dtable[26+i]= 'a'+i;
dtable[26+i+9]= 'j'+i;
}
for(i= 0;i<8;i++){
dtable[i+18]= 'S'+i;
dtable[26+i+18]= 's'+i;
}
for(i= 0;i<10;i++){
dtable[52+i]= '0'+i;
}
dtable[62]= '+';
dtable[63]= '/';


/*:12*/
#line 219 "base64.w"
;

while(!hiteof){
byte igroup[3],ogroup[4];
int c,n;

igroup[0]= igroup[1]= igroup[2]= 0;
for(n= 0;n<3;n++){
c= inchar();
if(c==EOF){
hiteof= TRUE;
break;
}
igroup[n]= (byte)c;
}
if(n> 0){
ogroup[0]= dtable[igroup[0]>>2];
ogroup[1]= dtable[((igroup[0]&3)<<4)|(igroup[1]>>4)];
ogroup[2]= dtable[((igroup[1]&0xF)<<2)|(igroup[2]>>6)];
ogroup[3]= dtable[igroup[2]&0x3F];





if(n<3){
ogroup[3]= '=';
if(n<2){
ogroup[2]= '=';
}
}
for(i= 0;i<4;i++){
ochar(ogroup[i]);
}
}
}
if(fputs(eol,fo)==EOF){
exit(1);
}
}

/*:11*//*13:*/
#line 299 "base64.w"


static void decode(void)
{
int i;

/*14:*/
#line 362 "base64.w"


for(i= 0;i<255;i++){
dtable[i]= 0x80;
}
for(i= 'A';i<='I';i++){
dtable[i]= 0+(i-'A');
}
for(i= 'J';i<='R';i++){
dtable[i]= 9+(i-'J');
}
for(i= 'S';i<='Z';i++){
dtable[i]= 18+(i-'S');
}
for(i= 'a';i<='i';i++){
dtable[i]= 26+(i-'a');
}
for(i= 'j';i<='r';i++){
dtable[i]= 35+(i-'j');
}
for(i= 's';i<='z';i++){
dtable[i]= 44+(i-'s');
}
for(i= '0';i<='9';i++){
dtable[i]= 52+(i-'0');
}
dtable['+']= 62;
dtable['/']= 63;
dtable['=']= 0;


/*:14*/
#line 305 "base64.w"
;

while(TRUE){
byte a[4],b[4],o[3];

for(i= 0;i<4;i++){
int c= insig();

if(c==EOF){
if(errcheck&&(i> 0)){
fprintf(stderr,"Input file incomplete.\n");
exit(1);
}
return;
}
if(dtable[c]&0x80){
if(errcheck){
fprintf(stderr,"Illegal character '%c' in input file.\n",c);
exit(1);
}

i--;
continue;
}
a[i]= (byte)c;
b[i]= (byte)dtable[c];
}
o[0]= (b[0]<<2)|(b[1]>>4);
o[1]= (b[1]<<4)|(b[2]>>2);
o[2]= (b[2]<<6)|b[3];
i= a[2]=='='?1:(a[3]=='='?2:3);
if(fwrite(o,i,1,fo)==EOF){
exit(1);
}
if(i<3){
return;
}
}

}

/*:13*//*16:*/
#line 398 "base64.w"


static void usage(void)
{
printf("%s  --  Encode/decode file as base64.  Call:\n",PRODUCT);
printf("            %s [-e / -d] [options] [infile] [outfile]\n",PRODUCT);
printf("\n");
printf("Options:\n");
printf("           --copyright       Print copyright information\n");
printf("           -d, --decode      Decode base64 encoded file\n");
printf("           -e, --encode      Encode file into base64\n");
printf("           -n, --noerrcheck  Ignore errors when decoding\n");
printf("           -u, --help        Print this message\n");
printf("           --version         Print version number\n");
printf("\n");
printf("by John Walker\n");
printf("http://www.fourmilab.ch/\n");
}

/*:16*//*17:*/
#line 419 "base64.w"


int main(int argc,char*argv[])
{
extern char*optarg;
extern int optind;

int f,decoding= FALSE,opt;
#ifdef FORCE_BINARY_IO
int in_std= TRUE,out_std= TRUE;
#endif
char*cp;







fi= stdin;
fo= stdout;

/*18:*/
#line 457 "base64.w"

while((opt= getopt(argc,argv,"denu-:"))!=-1){
switch(opt){
case'd':
decoding= TRUE;
break;

case'e':
decoding= FALSE;
break;

case'n':
errcheck= FALSE;
break;

case'u':
case'?':
usage();
return 0;

case'-':
switch(optarg[0]){
case'c':
printf("This program is in the public domain.\n");
return 0;

case'd':
decoding= TRUE;
break;

case'e':
decoding= FALSE;
break;

case'h':
usage();
return 0;

case'n':
errcheck= FALSE;
break;

case'v':
printf("%s %s\n",PRODUCT,VERSION);
printf("Last revised: %s\n",REVDATE);
printf("The latest version is always available\n");
printf("at http://www.fourmilab.ch/webtools/base64\n");
return 0;
}
}
}

/*:18*/
#line 441 "base64.w"
;
/*19:*/
#line 514 "base64.w"

f= 0;
for(;optind<argc;optind++){
cp= argv[optind];
switch(f){













case 0:
if(strcmp(cp,"-")!=0){
if((fi= fopen(cp,
#ifdef FORCE_BINARY_IO
decoding?"r":"rb"
#else
"r"
#endif
))==NULL){
fprintf(stderr,"Cannot open input file %s\n",cp);
return 2;
}
#ifdef FORCE_BINARY_IO
in_std= FALSE;
#endif
}
f++;
break;

case 1:
if(strcmp(cp,"-")!=0){
if((fo= fopen(cp,
#ifdef FORCE_BINARY_IO
decoding?"wb":"w"
#else
"w"
#endif
))==NULL){
fprintf(stderr,"Cannot open output file %s\n",cp);
return 2;
}
#ifdef FORCE_BINARY_IO
out_std= FALSE;
#endif
}
f++;
break;

default:
fprintf(stderr,"Too many file names specified.\n");
usage();
return 2;
}
}

/*:19*/
#line 442 "base64.w"
;
/*20:*/
#line 590 "base64.w"

#ifdef FORCE_BINARY_IO
if((decoding&&out_std)||((!decoding)&&in_std)){
#ifdef _WIN32


_setmode(_fileno(decoding?fo:fi),O_BINARY);
#endif
}
#endif


/*:20*/
#line 443 "base64.w"
;

if(decoding){
decode();
}else{
encode();
}
return 0;
}

/*:17*/
