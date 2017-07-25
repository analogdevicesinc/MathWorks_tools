-------------------------------------------------------------------------------
-- $Id: util_reduced_logic.vhd,v 1.1 2003/10/03 04:45:40 abq_ip Exp $
-------------------------------------------------------------------------------
-- util_reduced_logic.vhd - Entity and architecture
--
--  ***************************************************************************
--  **  Copyright(C) 2003 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        util_reduced_logic.vhd
--
-- Description:     
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              util_reduced_logic.vhd
--
-------------------------------------------------------------------------------
-- Author:          goran
-- Revision:        $Revision: 1.1 $
-- Date:            $Date: 2003/10/03 04:45:40 $
--
-- History:
--   goran  2003-06-06    First Version
--
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity util_reduced_logic is
  generic (
    C_OPERATION : string  := "and";
    C_SIZE      : integer := 8
    );
  port (
    Op1 : in  std_logic_vector(C_SIZE-1 downto 0);
    Res : out std_logic
    );
end util_reduced_logic;

architecture IMP of util_reduced_logic is

  function LowerCase_Char(char : character) return character is
  begin
    -- If char is not an upper case letter then return char
    if char < 'A' or char > 'Z' then
      return char;
    end if;
    -- Otherwise map char to its corresponding lower case character and
    -- return that
    case char is
      when 'A'    => return 'a'; when 'B' => return 'b'; when 'C' => return 'c'; when 'D' => return 'd';
      when 'E'    => return 'e'; when 'F' => return 'f'; when 'G' => return 'g'; when 'H' => return 'h';
      when 'I'    => return 'i'; when 'J' => return 'j'; when 'K' => return 'k'; when 'L' => return 'l';
      when 'M'    => return 'm'; when 'N' => return 'n'; when 'O' => return 'o'; when 'P' => return 'p';
      when 'Q'    => return 'q'; when 'R' => return 'r'; when 'S' => return 's'; when 'T' => return 't';
      when 'U'    => return 'u'; when 'V' => return 'v'; when 'W' => return 'w'; when 'X' => return 'x';
      when 'Y'    => return 'y'; when 'Z' => return 'z';
      when others => return char;
    end case;
  end LowerCase_Char;

  function LowerCase_String (s : string) return string is
    variable res : string(s'range);
  begin  -- function LoweerCase_String
    for I in s'range loop
      res(I) := LowerCase_Char(s(I));
    end loop;  -- I
    return res;
  end function LowerCase_String;

  constant C_Oper : string := LowerCase_String(C_OPERATION);
  
begin

  Use_AND: if (C_Oper = "and") generate

    AND_Proc: process (Op1) is
      variable temp : std_logic;
    begin  -- process AND_Proc
      temp := '1';
      for I in 0 to C_SIZE-1 loop
        temp := temp and Op1(I);
      end loop;  -- I
      res <= temp;
    end process AND_Proc;

  end generate Use_AND;

  Use_OR: if (C_Oper = "or") generate

    OR_Proc: process (Op1) is
      variable temp : std_logic;
    begin  -- process OR_Proc
      temp := '0';
      for I in 0 to C_SIZE-1 loop
        temp := temp or Op1(I);
      end loop;  -- I
      res <= temp;
    end process OR_Proc;

  end generate Use_OR;

  Use_XOR: if (C_Oper = "xor") generate

    XOR_Proc: process (Op1) is
      variable temp : std_logic;
    begin  -- process XOR_Proc
      temp := '0';
      for I in 0 to C_SIZE-1 loop
        temp := temp xor Op1(I);
      end loop;  -- I
      res <= temp;
    end process XOR_Proc;

  end generate Use_XOR;
  
end IMP;

