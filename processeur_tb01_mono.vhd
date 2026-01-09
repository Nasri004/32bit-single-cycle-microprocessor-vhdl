LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processeur_tb IS
END ENTITY;

ARCHITECTURE TEST OF processeur_tb IS

    -- Déclaration des signaux
    SIGNAL clk, reset : std_logic;
    SIGNAL Afficheur : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OK : boolean := true;

    -- Déclaration des tableaux de mémoire et registres
    TYPE memory_array_type IS ARRAY (0 TO 15) OF std_logic_vector(31 DOWNTO 0); -- Mémoire
    TYPE register_array_type IS ARRAY (0 TO 9) OF std_logic_vector(31 DOWNTO 0); -- Registres

    SIGNAL TEST_memory : memory_array_type := (OTHERS => (OTHERS => '0'));
    SIGNAL TEST_registers : register_array_type := (OTHERS => (OTHERS => '0'));
    SIGNAL TEST_registre_tempo : std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- Instantiation de l'unité sous test (UUT)
    UUT : ENTITY work.processeur
    PORT MAP (
        clk => clk,
        reset => reset,
        Afficheur => Afficheur
    );

    -- Génération du signal clock
    CLOCK: PROCESS
    BEGIN
        WHILE now <= 100 ns LOOP
            clk <= '0';
            WAIT FOR 5 ns;
            clk <= '1';
            WAIT FOR 5 ns;
        END LOOP;
        WAIT;
    END PROCESS;

    -- Processus de simulation et de test
    PROCESS
    BEGIN
        -- RESET
        reset <= '1';
        WAIT FOR 10 ns;
        reset <= '0';

        -- Initialisation de la mémoire
        FOR i IN 0 TO 15 LOOP
            TEST_memory(i) <= std_logic_vector(to_unsigned(i + 1, 32)); -- Remplissage mémoire
        END LOOP;

        -- Initialisation des registres
        FOR i IN 0 TO 9 LOOP
            TEST_registers(i) <= (OTHERS => '0'); -- Initialisation des registres à zéro
        END LOOP;

        WAIT FOR 10 ns;

        -- Exécution des instructions de test
        -- MOV R1, 0x02
        TEST_registers(1) <= std_logic_vector(to_unsigned(2, 32));
        WAIT FOR 10 ns;

        -- MOV R2, 0x03
        TEST_registers(2) <= std_logic_vector(to_unsigned(3, 32));
        WAIT FOR 10 ns;

        -- ADD R3, R1, R2 (R3 = R1 + R2)
        TEST_registers(3) <= std_logic_vector(to_unsigned(
            to_integer(unsigned(TEST_registers(1))) + to_integer(unsigned(TEST_registers(2))), 
            32));
        WAIT FOR 10 ns;

        -- ADDI R4, R1, 0x55 (R4 = R1 + 0x55)
        TEST_registers(4) <= std_logic_vector(to_unsigned(
            to_integer(unsigned(TEST_registers(1))) + 16#55#, 
            32));
        WAIT FOR 10 ns;

        -- SUB R5, R4, R3 (R5 = R4 - R3)
        TEST_registers(5) <= std_logic_vector(to_unsigned(
            to_integer(unsigned(TEST_registers(4))) - to_integer(unsigned(TEST_registers(3))),
            32));
        WAIT FOR 10 ns;

        -- SUBI R6, R5, 0x01 (R6 = R5 - 0x01)
        TEST_registers(6) <= std_logic_vector(to_unsigned(
            to_integer(unsigned(TEST_registers(5))) - 1,
            32));
        WAIT FOR 10 ns;

        -- STR R4, 0 (R1) (Écriture dans la mémoire à l'adresse R1)
        TEST_memory(to_integer(unsigned(TEST_registers(1)))) <= TEST_registers(4);
        WAIT FOR 10 ns;

        -- LDR R8, 0 (R1) (Lecture dans la mémoire à l'adresse R1)
        TEST_registers(8) <= TEST_memory(to_integer(unsigned(TEST_registers(1))));
        WAIT FOR 10 ns;

        -- AND R9, R1, R2 (R9 = R1 AND R2)
        TEST_registers(9) <= std_logic_vector(unsigned(TEST_registers(1)) AND unsigned(TEST_registers(2)));
        WAIT FOR 10 ns;

        -- Vérification des résultats
        -- Mise à jour de l'afficheur avec les résultats
        Afficheur <= TEST_registers(3); -- Affiche le résultat de R3
        WAIT FOR 10 ns;
        Afficheur <= TEST_registers(4); -- Affiche le résultat de R4
        WAIT FOR 10 ns;
        Afficheur <= TEST_registers(5); -- Affiche le résultat de R5
        WAIT FOR 10 ns;
        Afficheur <= TEST_registers(6); -- Affiche le résultat de R6
        WAIT FOR 10 ns;

        -- Fin de simulation
        WAIT;
    END PROCESS;

END ARCHITECTURE;
