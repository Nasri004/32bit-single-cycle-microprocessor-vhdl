LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity unite_traitement_tb is
end;

architecture TEST of unite_traitement_tb is

    -- Signaux pour connecter l'unité de traitement
    signal clk, reset, RegWr, COM1, COM2, WrEn, RegSel: std_logic;
    signal OP : std_logic_vector(2 downto 0);
    signal flag : std_logic_vector(3 downto 0);
    signal Rd, Rn, Rm : std_logic_vector(3 downto 0);
    signal Imm : std_logic_vector(7 downto 0);
    signal B : std_logic_vector(31 downto 0);
    signal OK : boolean := true; -- Signal pour indiquer si les tests sont réussis

    -- Tableau pour les registres
    type reg_array is array(15 downto 0) of std_logic_vector(31 downto 0);
    signal registres : reg_array := (others => (others => '0'));

    -- Tableau pour la mémoire de données
    type mem_array is array(63 downto 0) of std_logic_vector(31 downto 0);
    signal memoire : mem_array := (others => (others => '0'));

    -- Signal pour suivre les instructions exécutées
    signal instruction : std_logic_vector(31 downto 0);

begin

    -- Instanciation de l'unité de traitement
    UUT : entity work.unite_traitement
        port map(
            clk => clk,
            reset => reset,
            RegWr => RegWr,
            WrEn => WrEn,
            COM1 => COM1,
            COM2 => COM2,
            RegSel => RegSel,
            OP => OP,
            Rn => Rn,
            Rm => Rm,
            Rd => Rd,
            flag => flag,
            B => B,
            Imm => Imm
        );

    -- Génération du signal d'horloge
    CLOCK: process
    begin
        while now < 200 ns loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Processus de test
    process
    begin
        -- Phase 1 : Initialisation
        reset <= '1';
        RegWr <= '0';
        RegSel <= '0';
        WrEn <= '0';
        COM1 <= '0';
        COM2 <= '0';
        OP <= "000";
        Rn <= (others => '0');
        Rm <= (others => '0');
        Rd <= (others => '0');
        Imm <= (others => '0');
        instruction <= X"00000000"; -- Aucune instruction exécutée
        wait for 20 ns;
        reset <= '0';

        -- Phase 2 : Chargement de valeurs dans les registres
        -- Charger 1 dans Rd=0001
        Imm <= "00000001"; -- Valeur immédiate 1
        COM1 <= '1'; -- Sélectionner Imm au lieu de busB
        OP <= "001"; -- Opération de chargement
        Rd <= "0001"; -- Registre cible (R1)
        RegWr <= '1'; -- Activer l'écriture
        instruction <= X"00000001"; -- Instruction de chargement immédiat
        wait for 20 ns;
        registres(to_integer(unsigned(Rd))) <= std_logic_vector(to_unsigned(1, 32));

        -- Charger 2 dans Rd=0010
        Imm <= "00000010"; -- Valeur immédiate 2
        Rd <= "0010"; -- Registre cible (R2)
        instruction <= X"00000002"; -- Instruction de chargement immédiat
        wait for 20 ns;
        registres(to_integer(unsigned(Rd))) <= std_logic_vector(to_unsigned(2, 32));

        -- Phase 3 : Opérations arithmétiques
        -- Addition : 1 (Rn=0001) + 2 (Rm=0010) -> Rd=0011
        COM1 <= '0'; -- Sélectionner busB au lieu de Imm
        OP <= "000"; -- Addition
        Rn <= "0001"; -- Registre source 1 (R1 = 1)
        Rm <= "0010"; -- Registre source 2 (R2 = 2)
        Rd <= "0011"; -- Registre cible (R3)
        instruction <= X"00000003"; -- Instruction d'addition
        wait for 20 ns;
        registres(to_integer(unsigned(Rd))) <= std_logic_vector(unsigned(registres(to_integer(unsigned(Rn)))) + unsigned(registres(to_integer(unsigned(Rm)))));

        -- Vérification : 1 + 2 = 3
        if B /= "00000000000000000000000000000011" then
            OK <= false;
        end if;

        -- Soustraction : 3 (Rn=0011) - 1 (Rm=0001) -> Rd=0100
        OP <= "010"; -- Soustraction
        Rn <= "0011"; -- Registre source 1 (R3 = 3)
        Rm <= "0001"; -- Registre source 2 (R1 = 1)
        Rd <= "0100"; -- Registre cible (R4)
        instruction <= X"00000004"; -- Instruction de soustraction
        wait for 20 ns;
        registres(to_integer(unsigned(Rd))) <= std_logic_vector(unsigned(registres(to_integer(unsigned(Rn)))) - unsigned(registres(to_integer(unsigned(Rm)))));

        -- Vérification : 3 - 1 = 2
        if B /= "00000000000000000000000000000010" then
            OK <= false;
        end if;

        -- Phase 4 : Test des instructions immédiates
        -- Addition avec une valeur immédiate : 1 (Rn=0001) + 85 (Imm) -> Rd=0101
        Imm <= "01010101"; -- Valeur immédiate 85
        COM1 <= '1'; -- Sélectionner Imm
        OP <= "000"; -- Addition
        Rn <= "0001"; -- Registre source (R1 = 1)
        Rd <= "0101"; -- Registre cible (R5)
        instruction <= X"00000005"; -- Instruction d'addition immédiate
        wait for 20 ns;
        registres(to_integer(unsigned(Rd))) <= std_logic_vector(unsigned(registres(to_integer(unsigned(Rn)))) + unsigned(Imm));

        -- Vérification : 1 + 85 = 86
        if B /= "00000000000000000000000001010110" then
            OK <= false;
        end if;

        -- Soustraction avec une valeur immédiate : 86 (Rn=0101) - 1 (Imm) -> Rd=0110
        Imm <= "00000001"; -- Valeur immédiate 1
        OP <= "010"; -- Soustraction
        Rn <= "0101"; -- Registre source (R5 = 86)
        Rd <= "0110"; -- Registre cible (R6)
        instruction <= X"00000006"; -- Instruction de soustraction immédiate
        wait for 20 ns;
        registres(to_integer(unsigned(Rd))) <= std_logic_vector(unsigned(registres(to_integer(unsigned(Rn)))) - unsigned(Imm));

        -- Vérification : 86 - 1 = 85
        if B /= "00000000000000000000000001010101" then
            OK <= false;
        end if;

        -- Phase 5 : Opérations mémoire
        -- Écriture dans la mémoire
        WrEn <= '1'; -- Activer l'écriture dans la mémoire
        Rm <= "0010"; -- Donnée source (R2 = 2)
        instruction <= X"00000007"; -- Instruction d'écriture mémoire
        memoire(0) <= registres(to_integer(unsigned(Rm)));
        wait for 20 ns;

        -- Lecture de la mémoire dans Rd=1000
        WrEn <= '0'; -- Désactiver l'écriture
        Rd <= "1000"; -- Charger la mémoire dans R8
        instruction <= X"00000008"; -- Instruction de lecture mémoire
        registres(to_integer(unsigned(Rd))) <= memoire(0);
        wait for 20 ns;

        -- Fin du test
        wait;
    end process;

end TEST;

