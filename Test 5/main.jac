import {node::{state,ansstate, aboutstate, appointdate, closing_state}, edge::{transition}, graph::{main_graph}} with "./graph.jac";
import {*} with "./walkers.jac";

walker init {

    root {
        spawn here --> graph::main_graph;
        spawn --> walker::talker;
    }
}


/*
Run Server:              jsctl

Run File:                jac run filename.jac
Run walker:              walker run walkername


Set Active:              sentinel register main.jac -set_active true
API:                     alias list

Create dot file:         jsctl graph get -mode dot -o _main.dot
Dot File Graphviz:       dot -Tpdf _main.dot -o _main.pdf 
                         dot -Tpng _main.dot -o _main.png


Dot and Jac is case sensitive

.jac
dot -Tpdf

*/