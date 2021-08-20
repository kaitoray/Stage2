PROGRAM CB_failure_Prot
  VAR
    CB_FDR1_failure : BOOL;
    CB_FDR4_failure : BOOL;
    CB1_22KV_failure : BOOL;
    CB3_22KV_failure : BOOL;
  END_VAR
  VAR
    Open_CB1_22KV AT %QX0.0 : BOOL;
    Open_CB2_22KV AT %QX0.1 : BOOL;
    Open_CB3_22KV AT %QX0.2 : BOOL;
    Open_CB_TRSF1 AT %QX0.3 : BOOL;
    Open_CB_TRSF2 AT %QX0.4 : BOOL;
    Reset_All_CB AT %IX0.0 : BOOL;
    Status_CB1_22KV AT %IX0.1 : BOOL;
    Status_CB3_22KV AT %IX0.2 : BOOL;
    Status_CB_FDR1 AT %IX0.3 : BOOL;
    Status_CB_FDR4 AT %IX0.4 : BOOL;
    Fault_on_FDR1_Current AT %IW0 : INT;
    Fault_on_FDR4_Current AT %IW1 : INT;
    Fault_on_22BUS1_Current AT %IW2 : INT;
    Fault_on_22BUS2_Current AT %IW3 : INT;
  END_VAR
  VAR
    Threshold500 : INT := 500;
    TON0 : TON;
    TON1 : TON;
    TON2 : TON;
    TON3 : TON;
    ABS27_OUT : INT;
    GT10_OUT : BOOL;
    AND47_OUT : BOOL;
    ABS39_OUT : INT;
    GT20_OUT : BOOL;
    AND14_OUT : BOOL;
    ABS50_OUT : INT;
    GT5_OUT : BOOL;
    AND23_OUT : BOOL;
    ABS53_OUT : INT;
    GT30_OUT : BOOL;
    AND34_OUT : BOOL;
  END_VAR

  Open_CB1_22KV := NOT(Reset_All_CB) AND Open_CB1_22KV OR CB_FDR1_failure;
  ABS27_OUT := ABS(Fault_on_FDR1_Current);
  GT10_OUT := GT(ABS27_OUT, Threshold500);
  AND47_OUT := AND(GT10_OUT, Status_CB_FDR1);
  TON0(IN := AND47_OUT, PT := T#2s);
  CB_FDR1_failure := TON0.Q;
  Open_CB3_22KV := NOT(Reset_All_CB) AND Open_CB3_22KV OR CB_FDR4_failure;
  ABS39_OUT := ABS(Fault_on_FDR4_Current);
  GT20_OUT := GT(ABS39_OUT, Threshold500);
  AND14_OUT := AND(GT20_OUT, Status_CB_FDR4);
  TON1(IN := AND14_OUT, PT := T#2s);
  CB_FDR4_failure := TON1.Q;
  Open_CB2_22KV := NOT(Reset_All_CB) AND Open_CB_TRSF1 OR CB1_22KV_failure;
  Open_CB_TRSF1 := NOT(Reset_All_CB) AND Open_CB_TRSF1 OR CB1_22KV_failure;
  ABS50_OUT := ABS(Fault_on_22BUS1_Current);
  GT5_OUT := GT(ABS50_OUT, Threshold500);
  AND23_OUT := AND(GT5_OUT, Status_CB1_22KV);
  TON2(IN := AND23_OUT, PT := T#2s);
  CB1_22KV_failure := TON2.Q;
  Open_CB2_22KV := NOT(Reset_All_CB) AND Open_CB_TRSF2 OR CB3_22KV_failure;
  Open_CB_TRSF2 := NOT(Reset_All_CB) AND Open_CB_TRSF2 OR CB3_22KV_failure;
  ABS53_OUT := ABS(Fault_on_22BUS2_Current);
  GT30_OUT := GT(ABS53_OUT, Threshold500);
  AND34_OUT := AND(GT30_OUT, Status_CB3_22KV);
  TON3(IN := AND34_OUT, PT := T#2s);
  CB3_22KV_failure := TON3.Q;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK TaskMain(INTERVAL := T#10ms,PRIORITY := 0);
    PROGRAM Inst0 WITH TaskMain : CB_failure_Prot;
  END_RESOURCE
END_CONFIGURATION
