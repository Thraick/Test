walker talker {
    has utterance;
    has startdisengage = false; // used this since close_state disengage wasn't working.
    has skipinput = false; // to skip input std.input
    can use.enc_question, use.enc_answer;
    has itemname; // to add to itemrequested
    has itemvalue; // to add to itemrequested
    has itemRequested= {}; // store item request after creating appointment


    if (startdisengage == true): disengage;
    if (skipinput != true): utterance = std.input("> ");

    q_enc = use.enc_question(utterance);
    a_enc = use.enc_answer(here.prompts); # can take lists or single strings
    
    qa_scores = {}; #stores a map of question-answer scores
    cf_threshold = 0.1; #scores below will be discarded
    cf_max = 0; #stores the highest score
    chosen_intent = ""; #the prompt with the highest score

    if (here.prompts != null){
        for i=0 to i<(here.prompts).length by i += 1 {

            cf = vector.cosine_sim(q_enc, a_enc[i]);

            qa_scores[here.prompts[i]] = cf;

            if( cf > cf_max && cf >= cf_threshold ) {
                cf_max = cf;
                chosen_intent = here.prompts[i];
            }
        }
    }

    report {"utterance": utterance, "intent": chosen_intent, "scores": qa_scores};



    // custom chosen_intent
    back = ["back", "return"];
    yes = ["Yes","yes", "Accept", "Correct", "Right"];
    no = ["No","no","Wrong","Incorrect"];
    quit = ["Quit","quit","exit","Exit"];

    if (utterance in back): chosen_intent ="back";
    if (utterance in yes): chosen_intent ="yes";
    if (utterance in no): chosen_intent ="no";
    if (utterance in quit){
        std.out("Quitting");
        disengage;
    }
    
    state {

        take -[transition(intent == chosen_intent)]-> else{
            std.out("Hmm.. not sure what you mean. Here are some options to help: state", here.prompts);
            take here;
        }
    }
    ansstate {
        take -[transition(intent == "question")]-> ;
        skipinput =false; // used to skip input since it is not needed.

    }

    aboutstate {
        take -[transition(intent == chosen_intent)]-> else {
            std.out("Hmm.. not sure what you mean. Here are some options to help: aboutstate", here.prompts);
            take here;
        }
    }

    appointdate{
        here.data_input = chosen_intent;
        // add item requested.
        itemRequested[itemname]=itemvalue;
        take -[transition(intent == "question")]-> else {
            std.out("Hmm.. not sure what you mean. Here are some options to help: appointdate", here.prompts); // to remove
            take here;
        }
    }

    closing_state{
        disengage; // this is not working
    }


}
