library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Collect_Header is
  port (
    clk : in std_logic;
    reset : in std_logic;
    packet_in : in std_logic_vector (7 downto 0);
    SoP : in std_logic;
    EoP : in std_logic;
    vld : in std_logic;
    ready_FIFO : in std_logic;
    ready_hash : in std_logic;

    ready_hdr : out std_logic;
    header_data : out std_logic_vector (95 downto 0);
    packet_forward : out std_logic_vector (7 downto 0);
    -- vld_hdr : in std_logic | for test.
    vld_hdr : out std_logic;
    hdr_SoP : out std_logic;
    hdr_EoP :out std_logic


  );
end entity;

architecture Collect_Header_arch of Collect_Header is

  -- type Statype is (idle, collect_header, );
    

  -- signal declarations
  signal srcaddr : std_logic_vector (31 downto 0) := x"00000000"; --Store source address here

  signal destaddr : std_logic_vector (31 downto 0) := x"00000000"; --Store destination address here

  signal srcport : std_logic_vector (15 downto 0) := x"0000"; -- fang source ports her
  
  signal destport : std_logic_vector (15 downto 0) := x"0000"; -- fang destsource ports her
  
  signal iter : integer := 0;
  signal tothemoon : std_logic_vector (95 downto 0) := x"000000000000000000000000";
  
  signal store0 : std_logic_vector (7 downto 0) := x"00";
  signal store1 : std_logic_vector (7 downto 0) := x"00";
  signal store2 : std_logic_vector (7 downto 0) := x"00";

  signal intvld_hdr : std_logic;
  signal forwardSoP : std_logic;
  signal forwardEoP : std_logic;
  

begin






  Collect : process (clk, reset)
  begin
    if reset = '1' then
      srcaddr <= x"00000000";
      destaddr <= x"00000000";
      srcport <= x"0000";
      destport <= x"0000";


      iter <= 0;
    elsif Rising_edge(clk) then
      
      iter <= iter + 1;
      hdr_SoP <= SoP;
      hdr_EoP <= EoP;

      if SoP = '1' and clk'event then
        iter <= 0;
        srcaddr <= x"00000000";
        destaddr <= x"00000000";
        srcport <= x"0000";
        destport <= x"0000";
      end if;

      if iter >= 11 and iter <= 14 then -- SRCADDR
        if iter = 11 then
          store0 <= packet_in;
        end if;
        if iter = 12 then
          store1 <= packet_in;
        end if;
        if iter = 13 then
          store2 <= packet_in;
        end if;
        
        srcaddr <= store0 & store1 & store2 & packet_in;

      end if; 

      
      if iter >= 15 and iter <= 18 then -- DESTADDR
        if iter = 15 then
          store0 <= packet_in;
        end if;
        if iter = 16 then
          store1 <= packet_in;
        end if;
        if iter = 17 then
          store2 <= packet_in;
        end if;
        
        destaddr <= store0 & store1 & store2 & packet_in;
      end if;

      if iter >= 19 and iter <= 20 then
        if iter = 19 then
          store0 <= packet_in;
        end if;
        srcport <= store0 & packet_in;
      end if;


      if iter >= 21 and iter <= 22 then
        if iter = 21 then
          store0 <= packet_in;
        end if;
        destport <= store0 & packet_in;
      end if;

      if iter = 25 then
        tothemoon <= srcaddr & destaddr & srcport & destport;
      end if;

      if ready_hash = '1' and intvld_hdr = '1' then 
        header_data <= tothemoon; 
      else
        header_data <= x"000000000000000000000000";
      end if;

      if ready_FIFO = '1' and intvld_hdr = '1' then
        if SoP = '1' then
          hdr_SoP <= '1';
        end if;
      packet_forward <= packet_in;
      if EoP = '1' then
        hdr_EoP <= '1';
      end if;
      else
        packet_forward <= x"00";
      end if;

    end if;    

  end process;

end architecture;
