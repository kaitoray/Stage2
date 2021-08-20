PROGRAM OverCurrent_FDR
  VAR
    Short_Circuit_FDR1 : BOOL;
    Short_Circuit_FDR2 : BOOL;
    Short_Circuit_FDR3 : BOOL;
    Short_Circuit_FDR4 : BOOL;
    Short_Circuit_22BUS1 : BOOL;
    Short_Circuit_22BUS2 : BOOL;
  END_VAR
  VAR
    Open_CB_FDR1 AT %QX0.0 : BOOL;
    Open_CB_FDR2 AT %QX0.1 : BOOL;
    Open_CB_FDR3 AT %QX0.2 : BOOL;
    Open_CB_FDR4 AT %QX0.3 : BOOL;
    Open_CB1_22KV AT %QX0.4 : BOOL;
    Open_CB3_22KV AT %QX0.5 : BOOL;
    Reset_All_CB AT %IX0.0 : BOOL;
    Current_FDR1 AT %IW0 : INT;
    Current_FDR2 AT %IW1 : INT;
    Current_FDR3 AT %IW2 : INT;
    Current_FDR4 AT %IW3 : INT;
    Fault_on_FDR1_Current AT %IW4 : INT;
    Fault_on_FDR2_Current AT %IW5 : INT;
    Fault_on_FDR3_Current AT %IW6 : INT;
    Fault_on_FDR4_Current AT %IW7 : INT;
    Fault_on_22BUS1_Current AT %IW8 : INT;
    Fault_on_22BUS2_Current AT %IW9 : INT;
  END_VAR
  VAR
    Threshold500 : INT := 500;
    ABS27_OUT : INT;
    GT10_OUT : BOOL;
    ABS26_OUT : INT;
    GT4_OUT : BOOL;
    ABS19_OUT : INT;
    GT15_OUT : BOOL;
    ABS39_OUT : INT;
    GT20_OUT : BOOL;
    ABS50_OUT : INT;
    GT47_OUT : BOOL;
    ABS55_OUT : INT;
    GT51_OUT : BOOL;
  END_VAR

  ABS27_OUT := ABS(Fault_on_FDR1_Current);
  GT10_OUT := GT(ABS27_OUT, Threshold500);
  Short_Circuit_FDR1 := GT10_OUT;
  Open_CB_FDR1 := NOT(Reset_All_CB) AND Open_CB_FDR1 OR Short_Circuit_FDR1;
  ABS26_OUT := ABS(Fault_on_FDR2_Current);
  GT4_OUT := GT(ABS26_OUT, Threshold500);
  Short_Circuit_FDR2 := GT4_OUT;
  Open_CB_FDR2 := NOT(Reset_All_CB) AND Open_CB_FDR2 OR Short_Circuit_FDR2;
  ABS19_OUT := ABS(Fault_on_FDR3_Current);
  GT15_OUT := GT(ABS19_OUT, Threshold500);
  Short_Circuit_FDR3 := GT15_OUT;
  Open_CB_FDR3 := NOT(Reset_All_CB) AND Open_CB_FDR3 OR Short_Circuit_FDR3;
  ABS39_OUT := ABS(Fault_on_FDR4_Current);
  GT20_OUT := GT(ABS39_OUT, Threshold500);
  Short_Circuit_FDR4 := GT20_OUT;
  Open_CB_FDR4 := NOT(Reset_All_CB) AND Open_CB_FDR4 OR Short_Circuit_FDR4;
  ABS50_OUT := ABS(Fault_on_22BUS1_Current);
  GT47_OUT := GT(ABS50_OUT, Threshold500);
  Short_Circuit_22BUS1 := GT47_OUT;
  Open_CB1_22KV := NOT(Reset_All_CB) AND Open_CB1_22KV OR Short_Circuit_22BUS1;
  ABS55_OUT := ABS(Fault_on_22BUS2_Current);
  GT51_OUT := GT(ABS55_OUT, Threshold500);
  Short_Circuit_22BUS2 := GT51_OUT;
  Open_CB3_22KV := NOT(Reset_All_CB) AND Open_CB3_22KV OR Short_Circuit_22BUS2;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK TaskMain(INTERVAL := T#10ms,PRIORITY := 0);
    PROGRAM Inst0 WITH TaskMain : OverCurrent_FDR;
  END_RESOURCE
END_CONFIGURATION
