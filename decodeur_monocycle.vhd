library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decodeur_instructions is
    port (
        Instruction, PSR : in std_logic_vector(31 downto 0);
        nPC_SEL, RegWr, RegSel, ALUSrc, RegAff, MemWr, PSREn, WrSrc : out std_logic;
        ALUCtrl : out std_logic_vector(2 downto 0)
    );
end entity;

architecture Behavorial of decodeur_instructions is

    -- Déclarer le type ici dans l'architecture
    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, B, BLT, UNDEFINED);
    signal instr_courante : enum_instruction;
    signal N, C, Z, V : std_logic;

begin    
    process (Instruction, PSR)
    begin
        -- Décodage de l'instruction
        if (Instruction(27 downto 26) = "00") then
            case Instruction(24 downto 21) is
                when "1101" => instr_courante <= MOV; -- MOV
                when "1010" => instr_courante <= CMP; -- CMP
                when "0100" =>
                    if Instruction(25) = '1' then
                        instr_courante <= ADDi; -- ADDi
                    elsif Instruction(25) = '0' then
                        instr_courante <= ADDr; -- ADDr
                    else
                        instr_courante <= UNDEFINED;
                    end if;
                when others => instr_courante <= UNDEFINED;
            end case;

        elsif (Instruction(27 downto 26) = "01") then
            if (Instruction(20) = '0') then
                instr_courante <= STR; -- Store
            elsif (Instruction(20) = '1') then
                instr_courante <= LDR; -- Load
            else
                instr_courante <= UNDEFINED;
            end if;

        elsif (Instruction(27 downto 25) = "101") then
            if Instruction(31 downto 28) = "1011" then -- cond = LT
                instr_courante <= BLT; -- BLT
            elsif Instruction(31 downto 28) = "1110" then -- cond = AL
                if Instruction(24) = '0' then
                    instr_courante <= B; -- B
                elsif Instruction(24) = '1' then
                    instr_courante <= UNDEFINED; -- BAL (NOT IMPLEMENTED)
                else
                    instr_courante <= UNDEFINED;
                end if;
            else
                instr_courante <= UNDEFINED;
            end if;

        else
            instr_courante <= UNDEFINED;
        end if;

        -- Extraction des flags
        N <= PSR(28);
        C <= PSR(29);
        Z <= PSR(30);
        V <= PSR(31);

        -- Comportement selon l'instruction
        case instr_courante is
            when ADDi =>
                nPC_SEL <= '0';
                RegWr <= '1';
                ALUSrc <= '1';
                ALUCtrl <= "000";
                PSREn <= '0';
                MemWr <= '0';
                WrSrc <= '0';
                RegSel <= '0';
                RegAff <= '0';
            when BLT =>
                if N = '1' then
                    nPC_SEL <= '1';
                else
                    nPC_SEL <= '0';
                end if;
                RegWr <= '0';
                ALUSrc <= '0';
                ALUCtrl <= "000";
                PSREn <= '0';
                MemWr <= '0';
                WrSrc <= '0';
                RegSel <= '0';
                RegAff <= '0';
            -- Ajoutez les autres instructions ici
            when others =>
                nPC_SEL <= '0';
                RegWr <= '0';
                ALUSrc <= '0';
                ALUCtrl <= "000";
                PSREn <= '0';
                MemWr <= '0';
                WrSrc <= '0';
                RegSel <= '0';
                RegAff <= '0';
        end case;
    end process;

end architecture Behavorial;

