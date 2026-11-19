`default_nettype none


module top_wrapper;

    //wire [27:0] io_in, io_out, io_oeb;
    // North UIO Wires: 6 Tiles x 20 bits = 120 bits total
    //   uio_top_fin:  Signals driven FROM fabric soft-logic TO external SoC/pads
    //   uio_top_fout: Signals driven FROM external SoC/pads INTO fabric soft-logic
    wire [119:0] uio_top_fin;
    wire [119:0] uio_top_fout;
    wire [119:0] uio_bot_fin;
    wire [119:0] uio_bot_fout;

    // Tile X1Y0: North UIO [19:0]
    (* keep, BEL="X1Y0.A" *) User_project_IO uio_top_x1 (
        .FIN0(uio_top_fin[0]),   .FIN1(uio_top_fin[1]),   .FIN2(uio_top_fin[2]),   .FIN3(uio_top_fin[3]),
        .FIN4(uio_top_fin[4]),   .FIN5(uio_top_fin[5]),   .FIN6(uio_top_fin[6]),   .FIN7(uio_top_fin[7]),
        .FIN8(uio_top_fin[8]),   .FIN9(uio_top_fin[9]),   .FIN10(uio_top_fin[10]), .FIN11(uio_top_fin[11]),
        .FIN12(uio_top_fin[12]), .FIN13(uio_top_fin[13]), .FIN14(uio_top_fin[14]), .FIN15(uio_top_fin[15]),
        .FIN16(uio_top_fin[16]), .FIN17(uio_top_fin[17]), .FIN18(uio_top_fin[18]), .FIN19(uio_top_fin[19]),
        .FOUT0(uio_top_fout[0]),   .FOUT1(uio_top_fout[1]),   .FOUT2(uio_top_fout[2]),   .FOUT3(uio_top_fout[3]),
        .FOUT4(uio_top_fout[4]),   .FOUT5(uio_top_fout[5]),   .FOUT6(uio_top_fout[6]),   .FOUT7(uio_top_fout[7]),
        .FOUT8(uio_top_fout[8]),   .FOUT9(uio_top_fout[9]),   .FOUT10(uio_top_fout[10]), .FOUT11(uio_top_fout[11]),
        .FOUT12(uio_top_fout[12]), .FOUT13(uio_top_fout[13]), .FOUT14(uio_top_fout[14]), .FOUT15(uio_top_fout[15]),
        .FOUT16(uio_top_fout[16]), .FOUT17(uio_top_fout[17]), .FOUT18(uio_top_fout[18]), .FOUT19(uio_top_fout[19])
    );

    // Tile X2Y0: North UIO [39:20]
    (* keep, BEL="X2Y0.A" *) User_project_IO uio_top_x2 (
        .FIN0(uio_top_fin[20]), .FIN1(uio_top_fin[21]), .FIN2(uio_top_fin[22]), .FIN3(uio_top_fin[23]),
        .FIN4(uio_top_fin[24]), .FIN5(uio_top_fin[25]), .FIN6(uio_top_fin[26]), .FIN7(uio_top_fin[27]),
        .FIN8(uio_top_fin[28]), .FIN9(uio_top_fin[29]), .FIN10(uio_top_fin[30]), .FIN11(uio_top_fin[31]),
        .FIN12(uio_top_fin[32]), .FIN13(uio_top_fin[33]), .FIN14(uio_top_fin[34]), .FIN15(uio_top_fin[35]),
        .FIN16(uio_top_fin[36]), .FIN17(uio_top_fin[37]), .FIN18(uio_top_fin[38]), .FIN19(uio_top_fin[39]),
        .FOUT0(uio_top_fout[20]), .FOUT1(uio_top_fout[21]), .FOUT2(uio_top_fout[22]), .FOUT3(uio_top_fout[23]),
        .FOUT4(uio_top_fout[24]), .FOUT5(uio_top_fout[25]), .FOUT6(uio_top_fout[26]), .FOUT7(uio_top_fout[27]),
        .FOUT8(uio_top_fout[28]), .FOUT9(uio_top_fout[29]), .FOUT10(uio_top_fout[30]), .FOUT11(uio_top_fout[31]),
        .FOUT12(uio_top_fout[32]), .FOUT13(uio_top_fout[33]), .FOUT14(uio_top_fout[34]), .FOUT15(uio_top_fout[35]),
        .FOUT16(uio_top_fout[36]), .FOUT17(uio_top_fout[37]), .FOUT18(uio_top_fout[38]), .FOUT19(uio_top_fout[39])
    );

    // Tile X3Y0: North UIO [59:40]
    (* keep, BEL="X3Y0.A" *) User_project_IO uio_top_x3 (
        .FIN0(uio_top_fin[40]), .FIN1(uio_top_fin[41]), .FIN2(uio_top_fin[42]), .FIN3(uio_top_fin[43]),
        .FIN4(uio_top_fin[44]), .FIN5(uio_top_fin[45]), .FIN6(uio_top_fin[46]), .FIN7(uio_top_fin[47]),
        .FIN8(uio_top_fin[48]), .FIN9(uio_top_fin[49]), .FIN10(uio_top_fin[50]), .FIN11(uio_top_fin[51]),
        .FIN12(uio_top_fin[52]), .FIN13(uio_top_fin[53]), .FIN14(uio_top_fin[54]), .FIN15(uio_top_fin[55]),
        .FIN16(uio_top_fin[56]), .FIN17(uio_top_fin[57]), .FIN18(uio_top_fin[58]), .FIN19(uio_top_fin[59]),
        .FOUT0(uio_top_fout[40]), .FOUT1(uio_top_fout[41]), .FOUT2(uio_top_fout[42]), .FOUT3(uio_top_fout[43]),
        .FOUT4(uio_top_fout[44]), .FOUT5(uio_top_fout[45]), .FOUT6(uio_top_fout[46]), .FOUT7(uio_top_fout[47]),
        .FOUT8(uio_top_fout[48]), .FOUT9(uio_top_fout[49]), .FOUT10(uio_top_fout[50]), .FOUT11(uio_top_fout[51]),
        .FOUT12(uio_top_fout[52]), .FOUT13(uio_top_fout[53]), .FOUT14(uio_top_fout[54]), .FOUT15(uio_top_fout[55]),
        .FOUT16(uio_top_fout[56]), .FOUT17(uio_top_fout[57]), .FOUT18(uio_top_fout[58]), .FOUT19(uio_top_fout[59])
    );

    // Tile X4Y0: North UIO [79:60]
    (* keep, BEL="X4Y0.A" *) User_project_IO uio_top_x4 (
        .FIN0(uio_top_fin[60]), .FIN1(uio_top_fin[61]), .FIN2(uio_top_fin[62]), .FIN3(uio_top_fin[63]),
        .FIN4(uio_top_fin[64]), .FIN5(uio_top_fin[65]), .FIN6(uio_top_fin[66]), .FIN7(uio_top_fin[67]),
        .FIN8(uio_top_fin[68]), .FIN9(uio_top_fin[69]), .FIN10(uio_top_fin[70]), .FIN11(uio_top_fin[71]),
        .FIN12(uio_top_fin[72]), .FIN13(uio_top_fin[73]), .FIN14(uio_top_fin[74]), .FIN15(uio_top_fin[75]),
        .FIN16(uio_top_fin[76]), .FIN17(uio_top_fin[77]), .FIN18(uio_top_fin[78]), .FIN19(uio_top_fin[79]),
        .FOUT0(uio_top_fout[60]), .FOUT1(uio_top_fout[61]), .FOUT2(uio_top_fout[62]), .FOUT3(uio_top_fout[63]),
        .FOUT4(uio_top_fout[64]), .FOUT5(uio_top_fout[65]), .FOUT6(uio_top_fout[66]), .FOUT7(uio_top_fout[67]),
        .FOUT8(uio_top_fout[68]), .FOUT9(uio_top_fout[69]), .FOUT10(uio_top_fout[70]), .FOUT11(uio_top_fout[71]),
        .FOUT12(uio_top_fout[72]), .FOUT13(uio_top_fout[73]), .FOUT14(uio_top_fout[74]), .FOUT15(uio_top_fout[75]),
        .FOUT16(uio_top_fout[76]), .FOUT17(uio_top_fout[77]), .FOUT18(uio_top_fout[78]), .FOUT19(uio_top_fout[79])
    );

    // Tile X5Y0: North UIO [99:80]
    (* keep, BEL="X5Y0.A" *) User_project_IO uio_top_x5 (
        .FIN0(uio_top_fin[80]), .FIN1(uio_top_fin[81]), .FIN2(uio_top_fin[82]), .FIN3(uio_top_fin[83]),
        .FIN4(uio_top_fin[84]), .FIN5(uio_top_fin[85]), .FIN6(uio_top_fin[86]), .FIN7(uio_top_fin[87]),
        .FIN8(uio_top_fin[88]), .FIN9(uio_top_fin[89]), .FIN10(uio_top_fin[90]), .FIN11(uio_top_fin[91]),
        .FIN12(uio_top_fin[92]), .FIN13(uio_top_fin[93]), .FIN14(uio_top_fin[94]), .FIN15(uio_top_fin[95]),
        .FIN16(uio_top_fin[96]), .FIN17(uio_top_fin[97]), .FIN18(uio_top_fin[98]), .FIN19(uio_top_fin[99]),
        .FOUT0(uio_top_fout[80]), .FOUT1(uio_top_fout[81]), .FOUT2(uio_top_fout[82]), .FOUT3(uio_top_fout[83]),
        .FOUT4(uio_top_fout[84]), .FOUT5(uio_top_fout[85]), .FOUT6(uio_top_fout[86]), .FOUT7(uio_top_fout[87]),
        .FOUT8(uio_top_fout[88]), .FOUT9(uio_top_fout[89]), .FOUT10(uio_top_fout[90]), .FOUT11(uio_top_fout[91]),
        .FOUT12(uio_top_fout[92]), .FOUT13(uio_top_fout[93]), .FOUT14(uio_top_fout[94]), .FOUT15(uio_top_fout[95]),
        .FOUT16(uio_top_fout[96]), .FOUT17(uio_top_fout[97]), .FOUT18(uio_top_fout[98]), .FOUT19(uio_top_fout[99])
    );

    // Tile X6Y0: North UIO [119:100]
    (* keep, BEL="X6Y0.A" *) User_project_IO uio_top_x6 (
        .FIN0(uio_top_fin[100]), .FIN1(uio_top_fin[101]), .FIN2(uio_top_fin[102]), .FIN3(uio_top_fin[103]),
        .FIN4(uio_top_fin[104]), .FIN5(uio_top_fin[105]), .FIN6(uio_top_fin[106]), .FIN7(uio_top_fin[107]),
        .FIN8(uio_top_fin[108]), .FIN9(uio_top_fin[109]), .FIN10(uio_top_fin[110]), .FIN11(uio_top_fin[111]),
        .FIN12(uio_top_fin[112]), .FIN13(uio_top_fin[113]), .FIN14(uio_top_fin[114]), .FIN15(uio_top_fin[115]),
        .FIN16(uio_top_fin[116]), .FIN17(uio_top_fin[117]), .FIN18(uio_top_fin[118]), .FIN19(uio_top_fin[119]),
        .FOUT0(uio_top_fout[100]), .FOUT1(uio_top_fout[101]), .FOUT2(uio_top_fout[102]), .FOUT3(uio_top_fout[103]),
        .FOUT4(uio_top_fout[104]), .FOUT5(uio_top_fout[105]), .FOUT6(uio_top_fout[106]), .FOUT7(uio_top_fout[107]),
        .FOUT8(uio_top_fout[108]), .FOUT9(uio_top_fout[109]), .FOUT10(uio_top_fout[110]), .FOUT11(uio_top_fout[111]),
        .FOUT12(uio_top_fout[112]), .FOUT13(uio_top_fout[113]), .FOUT14(uio_top_fout[114]), .FOUT15(uio_top_fout[115]),
        .FOUT16(uio_top_fout[116]), .FOUT17(uio_top_fout[117]), .FOUT18(uio_top_fout[118]), .FOUT19(uio_top_fout[119])
    );

    // South UIO Wires: 6 Tiles x 20 bits = 120 bits total
    //   uio_bot_fin:  Signals driven FROM fabric soft-logic TO external SoC/pads
    //   uio_bot_fout: Signals driven FROM external SoC/pads INTO fabric soft-logic
    //wire [119:0] uio_bot_fin;
    //wire [119:0] uio_bot_fout;

    // Tile X1Y11: South UIO [19:0]
    (* keep, BEL="X1Y5.A" *) User_project_IO uio_bot_x1 (
        .FIN0(uio_bot_fin[0]),   .FIN1(uio_bot_fin[1]),   .FIN2(uio_bot_fin[2]),   .FIN3(uio_bot_fin[3]),
        .FIN4(uio_bot_fin[4]),   .FIN5(uio_bot_fin[5]),   .FIN6(uio_bot_fin[6]),   .FIN7(uio_bot_fin[7]),
        .FIN8(uio_bot_fin[8]),   .FIN9(uio_bot_fin[9]),   .FIN10(uio_bot_fin[10]), .FIN11(uio_bot_fin[11]),
        .FIN12(uio_bot_fin[12]), .FIN13(uio_bot_fin[13]), .FIN14(uio_bot_fin[14]), .FIN15(uio_bot_fin[15]),
        .FIN16(uio_bot_fin[16]), .FIN17(uio_bot_fin[17]), .FIN18(uio_bot_fin[18]), .FIN19(uio_bot_fin[19]),
        .FOUT0(uio_bot_fout[0]),   .FOUT1(uio_bot_fout[1]),   .FOUT2(uio_bot_fout[2]),   .FOUT3(uio_bot_fout[3]),
        .FOUT4(uio_bot_fout[4]),   .FOUT5(uio_bot_fout[5]),   .FOUT6(uio_bot_fout[6]),   .FOUT7(uio_bot_fout[7]),
        .FOUT8(uio_bot_fout[8]),   .FOUT9(uio_bot_fout[9]),   .FOUT10(uio_bot_fout[10]), .FOUT11(uio_bot_fout[11]),
        .FOUT12(uio_bot_fout[12]), .FOUT13(uio_bot_fout[13]), .FOUT14(uio_bot_fout[14]), .FOUT15(uio_bot_fout[15]),
        .FOUT16(uio_bot_fout[16]), .FOUT17(uio_bot_fout[17]), .FOUT18(uio_bot_fout[18]), .FOUT19(uio_bot_fout[19])
    );

    // Tile X2Y11: South UIO [39:20]
    (* keep, BEL="X2Y5.A" *) User_project_IO uio_bot_x2 (
        .FIN0(uio_bot_fin[20]), .FIN1(uio_bot_fin[21]), .FIN2(uio_bot_fin[22]), .FIN3(uio_bot_fin[23]),
        .FIN4(uio_bot_fin[24]), .FIN5(uio_bot_fin[25]), .FIN6(uio_bot_fin[26]), .FIN7(uio_bot_fin[27]),
        .FIN8(uio_bot_fin[28]), .FIN9(uio_bot_fin[29]), .FIN10(uio_bot_fin[30]), .FIN11(uio_bot_fin[31]),
        .FIN12(uio_bot_fin[32]), .FIN13(uio_bot_fin[33]), .FIN14(uio_bot_fin[34]), .FIN15(uio_bot_fin[35]),
        .FIN16(uio_bot_fin[36]), .FIN17(uio_bot_fin[37]), .FIN18(uio_bot_fin[38]), .FIN19(uio_bot_fin[39]),
        .FOUT0(uio_bot_fout[20]), .FOUT1(uio_bot_fout[21]), .FOUT2(uio_bot_fout[22]), .FOUT3(uio_bot_fout[23]),
        .FOUT4(uio_bot_fout[24]), .FOUT5(uio_bot_fout[25]), .FOUT6(uio_bot_fout[26]), .FOUT7(uio_bot_fout[27]),
        .FOUT8(uio_bot_fout[28]), .FOUT9(uio_bot_fout[29]), .FOUT10(uio_bot_fout[30]), .FOUT11(uio_bot_fout[31]),
        .FOUT12(uio_bot_fout[32]), .FOUT13(uio_bot_fout[33]), .FOUT14(uio_bot_fout[34]), .FOUT15(uio_bot_fout[35]),
        .FOUT16(uio_bot_fout[36]), .FOUT17(uio_bot_fout[37]), .FOUT18(uio_bot_fout[38]), .FOUT19(uio_bot_fout[39])
    );

    // Tile X3Y11: South UIO [59:40]
    (* keep, BEL="X3Y5.A" *) User_project_IO uio_bot_x3 (
        .FIN0(uio_bot_fin[40]), .FIN1(uio_bot_fin[41]), .FIN2(uio_bot_fin[42]), .FIN3(uio_bot_fin[43]),
        .FIN4(uio_bot_fin[44]), .FIN5(uio_bot_fin[45]), .FIN6(uio_bot_fin[46]), .FIN7(uio_bot_fin[47]),
        .FIN8(uio_bot_fin[48]), .FIN9(uio_bot_fin[49]), .FIN10(uio_bot_fin[50]), .FIN11(uio_bot_fin[51]),
        .FIN12(uio_bot_fin[52]), .FIN13(uio_bot_fin[53]), .FIN14(uio_bot_fin[54]), .FIN15(uio_bot_fin[55]),
        .FIN16(uio_bot_fin[56]), .FIN17(uio_bot_fin[57]), .FIN18(uio_bot_fin[58]), .FIN19(uio_bot_fin[59]),
        .FOUT0(uio_bot_fout[40]), .FOUT1(uio_bot_fout[41]), .FOUT2(uio_bot_fout[42]), .FOUT3(uio_bot_fout[43]),
        .FOUT4(uio_bot_fout[44]), .FOUT5(uio_bot_fout[45]), .FOUT6(uio_bot_fout[46]), .FOUT7(uio_bot_fout[47]),
        .FOUT8(uio_bot_fout[48]), .FOUT9(uio_bot_fout[49]), .FOUT10(uio_bot_fout[50]), .FOUT11(uio_bot_fout[51]),
        .FOUT12(uio_bot_fout[52]), .FOUT13(uio_bot_fout[53]), .FOUT14(uio_bot_fout[54]), .FOUT15(uio_bot_fout[55]),
        .FOUT16(uio_bot_fout[56]), .FOUT17(uio_bot_fout[57]), .FOUT18(uio_bot_fout[58]), .FOUT19(uio_bot_fout[59])
    );

    // Tile X4Y11: South UIO [79:60]
    (* keep, BEL="X4Y5.A" *) User_project_IO uio_bot_x4 (
        .FIN0(uio_bot_fin[60]), .FIN1(uio_bot_fin[61]), .FIN2(uio_bot_fin[62]), .FIN3(uio_bot_fin[63]),
        .FIN4(uio_bot_fin[64]), .FIN5(uio_bot_fin[65]), .FIN6(uio_bot_fin[66]), .FIN7(uio_bot_fin[67]),
        .FIN8(uio_bot_fin[68]), .FIN9(uio_bot_fin[69]), .FIN10(uio_bot_fin[70]), .FIN11(uio_bot_fin[71]),
        .FIN12(uio_bot_fin[72]), .FIN13(uio_bot_fin[73]), .FIN14(uio_bot_fin[74]), .FIN15(uio_bot_fin[75]),
        .FIN16(uio_bot_fin[76]), .FIN17(uio_bot_fin[77]), .FIN18(uio_bot_fin[78]), .FIN19(uio_bot_fin[79]),
        .FOUT0(uio_bot_fout[60]), .FOUT1(uio_bot_fout[61]), .FOUT2(uio_bot_fout[62]), .FOUT3(uio_bot_fout[63]),
        .FOUT4(uio_bot_fout[64]), .FOUT5(uio_bot_fout[65]), .FOUT6(uio_bot_fout[66]), .FOUT7(uio_bot_fout[67]),
        .FOUT8(uio_bot_fout[68]), .FOUT9(uio_bot_fout[69]), .FOUT10(uio_bot_fout[70]), .FOUT11(uio_bot_fout[71]),
        .FOUT12(uio_bot_fout[72]), .FOUT13(uio_bot_fout[73]), .FOUT14(uio_bot_fout[74]), .FOUT15(uio_bot_fout[75]),
        .FOUT16(uio_bot_fout[76]), .FOUT17(uio_bot_fout[77]), .FOUT18(uio_bot_fout[78]), .FOUT19(uio_bot_fout[79])
    );

    // Tile X5Y11: South UIO [99:80]
    (* keep, BEL="X5Y5.A" *) User_project_IO uio_bot_x5 (
        .FIN0(uio_bot_fin[80]), .FIN1(uio_bot_fin[81]), .FIN2(uio_bot_fin[82]), .FIN3(uio_bot_fin[83]),
        .FIN4(uio_bot_fin[84]), .FIN5(uio_bot_fin[85]), .FIN6(uio_bot_fin[86]), .FIN7(uio_bot_fin[87]),
        .FIN8(uio_bot_fin[88]), .FIN9(uio_bot_fin[89]), .FIN10(uio_bot_fin[90]), .FIN11(uio_bot_fin[91]),
        .FIN12(uio_bot_fin[92]), .FIN13(uio_bot_fin[93]), .FIN14(uio_bot_fin[94]), .FIN15(uio_bot_fin[95]),
        .FIN16(uio_bot_fin[96]), .FIN17(uio_bot_fin[97]), .FIN18(uio_bot_fin[98]), .FIN19(uio_bot_fin[99]),
        .FOUT0(uio_bot_fout[80]), .FOUT1(uio_bot_fout[81]), .FOUT2(uio_bot_fout[82]), .FOUT3(uio_bot_fout[83]),
        .FOUT4(uio_bot_fout[84]), .FOUT5(uio_bot_fout[85]), .FOUT6(uio_bot_fout[86]), .FOUT7(uio_bot_fout[87]),
        .FOUT8(uio_bot_fout[88]), .FOUT9(uio_bot_fout[89]), .FOUT10(uio_bot_fout[90]), .FOUT11(uio_bot_fout[91]),
        .FOUT12(uio_bot_fout[92]), .FOUT13(uio_bot_fout[93]), .FOUT14(uio_bot_fout[94]), .FOUT15(uio_bot_fout[95]),
        .FOUT16(uio_bot_fout[96]), .FOUT17(uio_bot_fout[97]), .FOUT18(uio_bot_fout[98]), .FOUT19(uio_bot_fout[99])
    );

    // Tile X6Y11: South UIO [119:100]
    (* keep, BEL="X6Y5.A" *) User_project_IO uio_bot_x6 (
        .FIN0(uio_bot_fin[100]), .FIN1(uio_bot_fin[101]), .FIN2(uio_bot_fin[102]), .FIN3(uio_bot_fin[103]),
        .FIN4(uio_bot_fin[104]), .FIN5(uio_bot_fin[105]), .FIN6(uio_bot_fin[106]), .FIN7(uio_bot_fin[107]),
        .FIN8(uio_bot_fin[108]), .FIN9(uio_bot_fin[109]), .FIN10(uio_bot_fin[110]), .FIN11(uio_bot_fin[111]),
        .FIN12(uio_bot_fin[112]), .FIN13(uio_bot_fin[113]), .FIN14(uio_bot_fin[114]), .FIN15(uio_bot_fin[115]),
        .FIN16(uio_bot_fin[116]), .FIN17(uio_bot_fin[117]), .FIN18(uio_bot_fin[118]), .FIN19(uio_bot_fin[119]),
        .FOUT0(uio_bot_fout[100]), .FOUT1(uio_bot_fout[101]), .FOUT2(uio_bot_fout[102]), .FOUT3(uio_bot_fout[103]),
        .FOUT4(uio_bot_fout[104]), .FOUT5(uio_bot_fout[105]), .FOUT6(uio_bot_fout[106]), .FOUT7(uio_bot_fout[107]),
        .FOUT8(uio_bot_fout[108]), .FOUT9(uio_bot_fout[109]), .FOUT10(uio_bot_fout[110]), .FOUT11(uio_bot_fout[111]),
        .FOUT12(uio_bot_fout[112]), .FOUT13(uio_bot_fout[113]), .FOUT14(uio_bot_fout[114]), .FOUT15(uio_bot_fout[115]),
        .FOUT16(uio_bot_fout[116]), .FOUT17(uio_bot_fout[117]), .FOUT18(uio_bot_fout[118]), .FOUT19(uio_bot_fout[119])
    );

    wire clk;
    (* keep *) Global_Clock clk_i (.CLK(clk));

    sequential_16bit_en top_i (
        .clk(clk),
        .io_in(uio_top_fout[27:0]),
        .io_out(uio_bot_fin[27:0]),
        .io_oeb(uio_top_fin[27:0])
    );

endmodule
`resetall
