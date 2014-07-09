library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.math.all;

entity cipher is
	port (
		din  : in  state;
		dout : out state
	);

	function sbox (din : byte) return byte is
		constant sbox_lut : lut := (
			x"63", x"7C", x"77", x"7B", x"F2", x"6B", x"6F", x"C5", x"30", x"01", x"67", x"2B", x"FE", x"D7", x"AB", x"76",
			x"CA", x"82", x"C9", x"7D", x"FA", x"59", x"47", x"F0", x"AD", x"D4", x"A2", x"AF", x"9C", x"A4", x"72", x"C0",
			x"B7", x"FD", x"93", x"26", x"36", x"3F", x"F7", x"CC", x"34", x"A5", x"E5", x"F1", x"71", x"D8", x"31", x"15",
			x"04", x"C7", x"23", x"C3", x"18", x"96", x"05", x"9A", x"07", x"12", x"80", x"E2", x"EB", x"27", x"B2", x"75",
			x"09", x"83", x"2C", x"1A", x"1B", x"6E", x"5A", x"A0", x"52", x"3B", x"D6", x"B3", x"29", x"E3", x"2F", x"84",
			x"53", x"D1", x"00", x"ED", x"20", x"FC", x"B1", x"5B", x"6A", x"CB", x"BE", x"39", x"4A", x"4C", x"58", x"CF",
			x"D0", x"EF", x"AA", x"FB", x"43", x"4D", x"33", x"85", x"45", x"F9", x"02", x"7F", x"50", x"3C", x"9F", x"A8",
			x"51", x"A3", x"40", x"8F", x"92", x"9D", x"38", x"F5", x"BC", x"B6", x"DA", x"21", x"10", x"FF", x"F3", x"D2",
			x"CD", x"0C", x"13", x"EC", x"5F", x"97", x"44", x"17", x"C4", x"A7", x"7E", x"3D", x"64", x"5D", x"19", x"73",
			x"60", x"81", x"4F", x"DC", x"22", x"2A", x"90", x"88", x"46", x"EE", x"B8", x"14", x"DE", x"5E", x"0B", x"DB",
			x"E0", x"32", x"3A", x"0A", x"49", x"06", x"24", x"5C", x"C2", x"D3", x"AC", x"62", x"91", x"95", x"E4", x"79",
			x"E7", x"C8", x"37", x"6D", x"8D", x"D5", x"4E", x"A9", x"6C", x"56", x"F4", x"EA", x"65", x"7A", x"AE", x"08",
			x"BA", x"78", x"25", x"2E", x"1C", x"A6", x"B4", x"C6", x"E8", x"DD", x"74", x"1F", x"4B", x"BD", x"8B", x"8A",
			x"70", x"3E", x"B5", x"66", x"48", x"03", x"F6", x"0E", x"61", x"35", x"57", x"B9", x"86", x"C1", x"1D", x"9E",
			x"E1", x"F8", x"98", x"11", x"69", x"D9", x"8E", x"94", x"9B", x"1E", x"87", x"E9", x"CE", x"55", x"28", x"DF",
			x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68", x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"16"
		);
	begin
		return sbox_lut(to_integer(unsigned(din)));
	end sbox;

	function sub_bytes (din : state) return state is
		variable tin : list;
		variable tout : list;
	begin
		tin := to_list(din);

		for i in 0 to 15 loop
			tout(i) := sbox(tin(i));
		end loop;

		return to_state(tout);
	end sub_bytes;

	function shift_rows (din : state) return state is
		variable tin : matrix;
		variable tout : matrix;
	begin
		tin := to_matrix(din);

		tout(0, 0) := tin(0, 0);
		tout(0, 1) := tin(0, 1);
		tout(0, 2) := tin(0, 2);
		tout(0, 3) := tin(0, 3);

		tout(1, 0) := tin(1, 1);
		tout(1, 1) := tin(1, 2);
		tout(1, 2) := tin(1, 3);
		tout(1, 3) := tin(1, 0);

		tout(2, 0) := tin(2, 2);
		tout(2, 1) := tin(2, 3);
		tout(2, 2) := tin(2, 0);
		tout(2, 3) := tin(2, 1);

		tout(3, 0) := tin(3, 3);
		tout(3, 1) := tin(3, 0);
		tout(3, 2) := tin(3, 1);
		tout(3, 3) := tin(3, 2);

		return to_state(tout);
	end shift_rows;

	function mix_columns (din : state) return state is
		variable tin : matrix;
		variable tout : matrix;
	begin
		tin := to_matrix(din);

		for col in 0 to 3 loop
			tout(0, col) := mul2(tin(0, col)) xor mul3(tin(1, col)) xor tin(2, col) xor tin(3, col);
			tout(1, col) := tin(0, col) xor mul2(tin(1, col)) xor mul3(tin(2, col)) xor tin(3, col);
			tout(2, col) := tin(0, col) xor tin(1, col) xor mul2(tin(2, col)) xor mul3(tin(3, col));
			tout(3, col) := mul3(tin(0, col)) xor tin(1, col) xor tin(2, col) xor mul2(tin(3, col));
		end loop;

		return to_state(tout);
	end mix_columns;
end cipher;

architecture behavioral of cipher is
begin

	dout <= mix_columns(din);

end behavioral;

