LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity processeur is
    port (
        clk, reset : in std_logic;
        Afficheur : out std_logic_vector(31 downto 0) -- Ajout du signal d'affichage
    );
end;

architecture behaviour of processeur is

    -- Déclaration des registres
    type reg_array is array (0 to 15) of std_logic_vector(31 downto 0);
    signal Registres : reg_array := (others => (others => '0'));

    -- Déclaration des signaux
    signal ALU_Result : std_logic_vector(31 downto 0);
    signal R0, R1, R2 : std_logic_vector(31 downto 0);

begin

    -- Logique principale
    process(clk, reset)
    begin
        if reset = '1' then
            -- Réinitialisation des registres
            Registres <= (others => (others => '0'));
            Afficheur <= (others => '0'); -- Réinitialisation de l'affichage
        elsif rising_edge(clk) then
            -- Exemples d'opérations
            -- Charger des valeurs dans les registres
            Registres(0) <= std_logic_vector(to_unsigned(5, 32));  -- R0 = 5
            Registres(1) <= std_logic_vector(to_unsigned(10, 32)); -- R1 = 10

            -- Addition R0 + R1 -> R2
            ALU_Result <= std_logic_vector(unsigned(Registres(0)) + unsigned(Registres(1)));
            Registres(2) <= ALU_Result; -- R2 = 15

            -- Mettre à jour l'Afficheur avec le contenu de R2
            Afficheur <= Registres(2);
        end if;
    end process;

end behaviour;
