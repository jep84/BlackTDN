#INCLUDE "NDJ.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSR001     � Autor � AP6 IDE          � Data �  25/10/10   ���
�������������������������������������������������������������������������͹��
���Descricao � GERAR RELATORIO DE TIPO DE DESPESA PRO ORIGEM DE RECURSO   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ORCAMENTO                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function PMSR004


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "RELATORIO DE TESTE"
Local cPict          := ""
Local titulo         := "RELATORIO CONSOLIDADO POR ORIGEM DE RECURSO"
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "G"
Private nomeprog     := "PMSR004" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0

Private cbcont       := 00 
Private cTitulo      := "RELATORIO CONSOLIDADO POR ORIGEM DE RECURSO"
Private CONTFL       := 01
Private m_pag        := 01 
Private aGraph       := {} 
Private wnrel        := "PMSR004" // Coloque aqui o nome do arquivo usado para impressao em disco
Cabec1 := "Origem de                                                      Pessoa         Pessoa                  Operacionais                                             "     
Cabec2 := "Recurso                                                      Juridica         Fisica        Pessoal   Administrat.        Capital         Viagem          Total"     
Private cString := "AF4"
dbSelectArea("AF4")
dbSetOrder(1)
//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
Pergunte("AF1REL")
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
    Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  25/10/10   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)




//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

WTPJ      = 0.00
WTPESSOAL = 0.00         
WTPF      = 0.00
WTVIAGEM  = 0.00
WTCUSTEIO = 0.00
WTCAPITAL = 0.00  
cQuery    = ""
Cquery = "SELECT AF1_FASE," 
cQuery += "AF1_ORCAME, " 
cQuery += "AF4_TIPOD, " 
cQuery += "AF4_XORIRE, "
cQuery += "AF4_VALOR "
cQuery += "FROM AF4010 JOIN AF1010 ON (AF4_FILIAL = AF1_FILIAL) AND (AF1_ORCAME = AF4_ORCAME) "
cQuery += "WHERE AF1010.D_E_L_E_T_ <> '*' AND AF4010.D_E_L_E_T_ <> '*'  " 
cQuery += " AND (AF4_XORIRE >= "+"'"+MV_PAR02+"'"+" AND AF4_XORIRE <= "+"'"+MV_PAR03+"')"  
cQuery += " AND (AF1_FASE >= "+"'"+MV_PAR04+"'"+" AND AF1_FASE <= "+"'"+MV_PAR05+"')"
cQuery += " ORDER BY AF4_XORIRE"
TcQuery ( cQuery ) ALIAS ( "TESTE" ) NEW 

dbSelectArea("TESTE")  

if MV_PAR01 = 1 .or. MV_PAR01 = 3
  While !EOF()
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif                                                                                   
   
  
   @nLin,00 PSAY TESTE->AF4_XORIRE    
   wtotalger = 0.00                  
   WORIRE   = TESTE->AF4_XORIRE     
   WTIPOD   = TESTE->AF4_TIPOD
   WPJ      = 0.00
   WPESSOAL = 0.00         
   WPF      = 0.00
   WVIAGEM  = 0.00
   WCUSTEIO = 0.00
   WCAPITAL = 0.00
   WVALTOT  = 0.00   
   While !EOF() .AND. (TESTE->AF4_XORIRE) = (WORIRE)               
          IF AF4_TIPOD = "MU" .OR. AF4_TIPOD = "HW" .OR. AF4_TIPOD = "MA" .OR. AF4_TIPOD = "SW" .OR. AF4_TIPOD = "BO" .OR. AF4_TIPOD = "MO"
             WCAPITAL +=  TESTE->AF4_VALOR 
          ENDIF
          IF AF4_TIPOD = "SJ"
             WPJ +=  TESTE->AF4_VALOR 
          ENDIF  
          IF AF4_TIPOD = "SF"
             WPF +=  TESTE->AF4_VALOR 
          ENDIF 
          IF AF4_TIPOD = "PE"
             WPESSOAL +=  TESTE->AF4_VALOR 
          ENDIF 
          IF AF4_TIPOD = "VI" .OR. AF4_TIPOD = "VN" 
             WVIAGEM +=  TESTE->AF4_VALOR 
          ENDIF              
          IF AF4_TIPOD = "OA"  
             WCUSTEIO +=  TESTE->AF4_VALOR 
          ENDIF                                                  
          dbSkip()
   EndDo 
   @nLin,55  PSAY WPJ       picture "@E 999,999,999.99" 
   @nLin,70  PSAY WPF       picture "@E 999,999,999.99"
   @nLin,85  PSAY WPESSOAL  picture "@E 999,999,999.99"
   @nLin,100 PSAY WCUSTEIO  picture "@E 999,999,999.99"
   @nLin,115 PSAY WCAPITAL  picture "@E 999,999,999.99"
   @nLin,130 PSAY WVIAGEM   picture "@E 999,999,999.99"
   WVALTOT = (WVIAGEM+WCAPITAL+WCUSTEIO+WPESSOAL+WPJ+WPF)  
   @nLin,145 PSAY WVALTOT   picture "@E 999,999,999.99"  
   aAdd(aGraph,{WORIRE, WVALTOT}) 
   nLin := nLin + 1 // Avanca a linha de impressao
   WTPJ      += WPJ
   WTPESSOAL += WPESSOAL         
   WTPF      += WPF
   WTVIAGEM  += WVIAGEM
   WTCUSTEIO += WCUSTEIO
   WTCAPITAL += WCAPITAL                  
  EndDo                           
  @nLin,00 PSAY Replicate("_",160)
  nLin := nLin + 1 // Avanca a linha de impressao   
  @nLin,12  PSAY "TOTAIS"      
  @nLin,55  PSAY WTPJ       picture "@E 999,999,999.99"      
  @nLin,70  PSAY WTPF       picture "@E 999,999,999.99" 
  @nLin,85  PSAY WTPESSOAL  picture "@E 999,999,999.99"
  @nLin,100 PSAY WTCUSTEIO  picture "@E 999,999,999.99"
  @nLin,115 PSAY WTCAPITAL  picture "@E 999,999,999.99"
  @nLin,130 PSAY WTVIAGEM  picture "@E 999,999,999.99"  
  @nLin,145 PSAY (WTVIAGEM+WTCAPITAL+WTCUSTEIO+WTPESSOAL+WTPJ+WTPF)  picture "@E 999,999,999.99"  
  nLin := nLin + 1 // Avanca a linha de impressao 
  @nLin,00 PSAY Replicate("_",160)
  //���������������������������������������������������������������������Ŀ
  //� Finaliza a execucao do relatorio...                                 �
  //�����������������������������������������������������������������������
//  If MsgYesNo("Deseja exibir o grafico ?")
//    MatGraph(Titulo,.T.,.T.,.T.,2,5,aGraph)
//  endif
   if MV_PAR01 = 1
     SET DEVICE TO SCREEN

     //���������������������������������������������������������������������Ŀ
     //� Se impressao em disco, chama o gerenciador de impressao...          �
     //�����������������������������������������������������������������������

     If aReturn[5]==1
        dbCommitAll()
        SET PRINTER TO
        OurSpool(wnrel)
     Endif
     MS_FLUSH()
   else 
    // Chama funcao generica para montagem de grafico
    /*
    �������������������������������������������������������������������������Ĵ��
    ���Descri��o � Funcao generica para montagem de dialog com grafico        ���
    �������������������������������������������������������������������������Ĵ��
    ���Parametros�                                                            ���
    ���        01� ExpC1 = Titulo da Janela                                   ���
    ���        02� ExpL1 = Flag indicando se inicializa grafico em 3 dimensoes���
    ���        03� ExpL2 = Flag indicando se mostra menu para mudar caracteris���
    ���          � ticas do grafico como tipo e numero de dimensoes (2 ou 3)  ���
    ���        04� ExpL3 = Indica se muda a cor em cada barra ou faixa de vlr ���
    ���        05� ExpN1 = Indica o tipo inicial do grafico                   ���
    ���        06� ExpN2 = Indica a cor inicial dos valores apresentados      ���
    ���        07� ExpA1 = Array com os dados a serem apresentados. Dimensoes:���
    ���          � [1] Nome a ser colocado no eixo x (Caracter)               ���
    ���          � [2] Valor do eixo y (Numerico)                             ���
    ���        08� ExpC2 = Alias do arquivo de trabalho que contem os dados   ���
    ���        09� ExpA2 = Array com os campos que devem ter o conteudo lido  ���
    ���          � [1] Nome do campo que tem os dados do eixo x (Caracter)    ���
    ���          � [2] Nome do campo que tem os valores do eixo y (Caracter)  ���
    �������������������������������������������������������������������������Ĵ��
    */

    MatGraph( "RELATORIO CONSOLIDADO POR ORIGEM DE RECURSO",.T.,.T.,.T.,2,2,aGraph)  
    MS_FLUSH() 
   endif
else
  nlin = 9
  wlinha = space(132)
  wlinha = "<table cellpadding='3' cellspacing='0' align='center' summary=''>"
  @nlin,00 psay wlinha
  nlin += 1  
  wlinha = space(132)   
  wlinha = "<tr><td colspan='8'><span><h2>RELATORIO CONSOLIDADO POR ORIGEM DE RECURSO</td></h2></span></tr>"
  @nlin,00 psay wlinha
  nlin += 1     
  wlinha = space(132)  
  wlinha = "<tr bgcolor='##ff9966'><td>Origem</td><td>Pessoa Juridica</td><td>Pessoa Fisica</td><td>Pessoal</td><td>Oper.Administ.</td><td>Capital</td><td>Viagem</td></tr>"
  @nlin,00 psay wlinha
  nlin += 1     
  wlinha = space(132)
  dbSelectArea("TESTE")  
//  set filter to AF4_XORIRE >= MV_PAR02 .AND. AF4_XORIRE <= MV_PAR03
  While !EOF()    
   wtotalger = 0.00                  
   WORIRE   = TESTE->AF4_XORIRE     
   WTIPOD   = TESTE->AF4_TIPOD
   WPJ      = 0.00
   WPESSOAL = 0.00         
   WPF      = 0.00
   WVIAGEM  = 0.00              
   
   WCUSTEIO = 0.00
   WCAPITAL = 0.00   
   While !EOF() .AND. TESTE->AF4_XORIRE = WORIRE           
          IF AF4_TIPOD = "MU" .OR. AF4_TIPOD = "HW" .OR. AF4_TIPOD = "MA" .OR. AF4_TIPOD = "SW" .OR. AF4_TIPOD = "BO" .OR. AF4_TIPOD = "MO"
             WCAPITAL +=  TESTE->AF4_VALOR 
          ENDIF
          IF AF4_TIPOD = "SJ"
             WPJ +=  TESTE->AF4_VALOR 
          ENDIF  
          IF AF4_TIPOD = "SF"
             WPF +=  TESTE->AF4_VALOR 
          ENDIF 
          IF AF4_TIPOD = "PE"
             WPESSOAL +=  TESTE->AF4_VALOR 
          ENDIF 
          IF AF4_TIPOD = "VI" .OR. AF4_TIPOD = "VN" 
             WVIAGEM +=  TESTE->AF4_VALOR 
          ENDIF              
          IF AF4_TIPOD = "OA"  
             WCUSTEIO +=  TESTE->AF4_VALOR 
          ENDIF                                                  
          dbSkip()
   EndDo 
   if mod(nlin,2) = 0
      wcor = "'##D3D3D3'"
   else 
      wcor = "'##FFFFFF'"   
   endif
   wlinha  = "<tr bgcolor="+wcor+">"
   wlinha += "<td>"+worire+"</td>"
   wlinha += "<td>"+strtran(str(wpj,12,2),".",",")+"</td>"
   wlinha += "<td>"+strtran(str(wpf,12,2),".",",")+"</td>"
   wlinha += "<td>"+strtran(str(wpessoal,12,2),".",",")+"</td>"
   wlinha += "<td>"+strtran(str(wcusteio,12,2),".",",")+"</td>"
   wlinha += "<td>"+strtran(str(wcapital,12,2),".",",")+"</td>"
   wlinha += "<td>"+strtran(str(wviagem,12,2),".",",")+"</td>"
   wlinha += "</tr>"
   @nlin,00 psay wlinha
   nlin += 1                  
   wlinha = space(132)  
//   dbSelectArea("TESTE")             
  EndDo                           
  wlinha ="</table>"
  If !ApOleClient("MsExcel")
     MsgStop("Microsoft Excel nao instalado.")  //"Microsoft Excel nao instalado."
    Return
  EndIf
  MS_FLUSH()       
  __CopyFile(__reldir+wnrel+".##R" , AllTrim(GetTempPath())+wnrel+".HTM")
    
  oExcelApp:= MsExcel():New()
  oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+wnrel+".HTM")
  oExcelApp:SetVisible(.T.)   
endif
Return

Static Function __Dummy( lRecursa )
    Local oException
    TRYEXCEPTION
        lRecursa := .F.
        IF !( lRecursa )
            BREAK
        EndIF
        lRecursa    := __Dummy( .F. )
        __cCRLF        := NIL
    CATCHEXCEPTION USING oException
    ENDEXCEPTION
Return( lRecursa )
