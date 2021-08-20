PROGRAM OverCurrent_TRSF1
  VAR
    Short_Circuit_TRSF1 : BOOL;
    Short_Circuit_66BUS : BOOL;
  END_VAR
  VAR
    Open_CB1_66KV AT %QX0.0 : BOOL;
    Open_CB2_66KV AT %QX0.1 : BOOL;
    Open_CB_TRSF1 AT %QX0.2 : BOOL;
    Open_CB2_22KV AT %QX0.3 : BOOL;
    Reset_All_CB AT %IX0.0 : BOOL;
    Current_CB1_66KV AT %IW0 : INT;
    Current_CB2_66KV AT %IW1 : INT;
    Current_TRSF1_W1 AT %IW2 : INT;
    Current_TRSF1_W2 AT %IW3 : INT;
    Current_CB_TRSF1 AT %IW4 : INT;
    Current_CB2_22KV AT %IW5 : INT;
    Current_Fault_on_TRSF1 AT %IW6 : INT;
    Current_Fault_on_66BUS1 AT %IW7 : INT;
  END_VAR
  VAR CONSTANT
    Threshold500 : INT := 500;
  END_VAR
  VAR
    GT15_OUT : BOOL;
    GT4_OUT : BOOL;
  END_VAR

  Open_CB2_22KV := NOT(NOT(Reset_All_CB) AND NOT(Open_CB2_22KV) AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_66BUS);
  Open_CB1_66KV := NOT(Reset_All_CB) AND NOT(Open_CB2_22KV) AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_66BUS;
  GT15_OUT := GT(Current_Fault_on_66BUS1, Threshold500);
  Short_Circuit_66BUS := GT15_OUT;
  Open_CB_TRSF1 := NOT(Reset_All_CB) AND NOT(Open_CB2_22KV) AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_66BUS;
  Open_CB2_66KV := TRUE;
  Open_CB2_22KV := NOT(NOT(Reset_All_CB) AND NOT(Open_CB2_22KV) AND Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_TRSF1);
  Open_CB1_66KV := NOT(Reset_All_CB) AND NOT(Open_CB2_22KV) AND Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_TRSF1;
  GT4_OUT := GT(Current_Fault_on_TRSF1, Threshold500);
  Short_Circuit_TRSF1 := GT4_OUT;
  Open_CB_TRSF1 := NOT(Reset_All_CB) AND NOT(Open_CB2_22KV) AND Open_CB2_66KV AND Open_CB1_66KV AND Open_CB_TRSF1 OR Short_Circuit_TRSF1;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK TaskMain(INTERVAL := T#10ms,PRIORITY := 0);
    PROGRAM Inst0 WITH TaskMain : OverCurrent_TRSF1;
  END_RESOURCE
END_CONFIGURATION
