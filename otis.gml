function load_saves(datafilename) {
    global.saves = data_broil_decode(datafilename, ",");
    global.saves[0][1] = json_parse(global.saves[0][1]);
}

function apply_save_changes(datafilename) {
    global.saves[0][1] = json_stringify(global.saves[0][1]);
    data_broil_encode(global.saves, ",", "playerdata");
}

function save_game(str, filename, savename, tag, autosave, datafilename) {
    if(!file_exists(datafilename)) {
        global.saves = [
            [
                "index",
                {
                    saves: {},
                    tags: {}
                }
            ]
        ];
    } else load_saves(datafilename);
    
    var indexsave = variable_struct_get(global.saves[0][1].saves, filename);
    if(indexsave == undefined) {
        var num = array_length(global.saves);
        var changetag = true;
        var oldtag = undefined;
        array_push(global.saves, [filename, str]);
        variable_struct_set(global.saves[0][1].saves, filename, {
            name: savename,
            tag: tag,
            autosave: autosave,
            number: num
        });
    } else {
        var oldtag = indexsave.tag;
        var changetag = oldtag == tag;
        indexsave.name = savename;
        indexsave.tag = tag;
        indexsave.autosave = autosave;
        global.saves[indexsave.number][1] = str;
    }
    
    var taglist = variable_struct_get(global.saves[0][1].tags, tag);
    if(taglist == undefined) {
        variable_struct_set(global.saves[0][1].tags, tag, {
            files: [filename]
        });
    } else if(changetag) {
        array_push(taglist.files, filename);
        if(oldtag != undefined) {
            taglist = variable_struct_get(global.saves[0][1].tags, oldtag);
            for(var i = 0; i < array_length(taglist.files); i++)
                if(taglist.files[i] == filename) {
                    array_delete(taglist.files, i, 1);
                    if(array_length(taglist.files) == 0) variable_struct_remove(global.saves[0][1].tags, oldtag);
                }
        }
    }
    
    apply_save_changes(datafilename);
}

function load_game(datafilename, filename) {
    load_saves(datafilename);
    return global.saves[variable_struct_get(global.saves[0][1].saves, filename).number][1];
}

function delete_save(datafilename, filename) {
    load_saves(datafilename);
    var tag = variable_struct_get(global.saves[0][1].saves, filename).tag;
    var number = variable_struct_get(global.saves[0][1].saves, filename).number;
    variable_struct_remove(global.saves[0][1].saves, filename);
    array_delete(global.saves, number, 1);
    
    var files = variable_struct_get_names(global.saves[0][1].saves);
    for(var i = 0; i < variable_struct_names_count(global.saves[0][1].saves); i++) {
        var j = variable_struct_get(global.saves[0][1].saves, files[i]);
        if(j.number > number) j.number--;
    }
    
    var taglist = variable_struct_get(global.saves[0][1].tags, tag);
    for(var i = 0; i < array_length(taglist.files); i++)
        if(taglist.files[i] == filename) {
            array_delete(taglist.files, i, 1);
            if(array_length(taglist.files) == 0) variable_struct_remove(global.saves[0][1].tags, tag);
        }
        
    apply_save_changes(datafilename);
}

function copy_save(datafilename, filename, suffix) {
    var str = load_game(datafilename, filename);
    var indexsave = variable_struct_get(global.saves[0][1].saves, filename);
    
    var copyname = filename + " copy";
    while(variable_struct_get(global.saves[0][1].saves, copyname) != undefined)
        copyname += " copy";
    
    save_game(str, copyname, indexsave.name + " " + suffix, indexsave.tag, indexsave.autosave, datafilename);
    
    return copyname;
}