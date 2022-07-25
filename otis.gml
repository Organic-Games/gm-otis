#macro OTIS_CHECK_HASH true

function otis_load_saves(masterfile) {
	var f = file_text_open_read(masterfile);
	global.saves = json_parse(file_text_read_string(f));
	file_text_close(f);
}

function otis_apply_save_changes(masterfile) {
	var f = file_text_open_write(masterfile);
	file_text_write_string(f, json_stringify(global.saves));
	file_text_close(f);
}

function otis_save_game(str, filename, savename, tag, autosave, masterfile) {
    if(!file_exists(masterfile)) {
        global.saves = [
            [
                "index",
                {
                    saves: {},
                    tags: {}
                }
            ]
        ];
    } else otis_load_saves(masterfile);
    
    var indexsave = variable_struct_get(global.saves[0][1].saves, filename);
    if(indexsave == undefined) {
        var hash = base64_encode(md5_string_utf8(str));
		var num = array_length(global.saves);
        var changetag = true;
        var oldtag = undefined;
        array_push(global.saves, [filename, str]);
        variable_struct_set(global.saves[0][1].saves, filename, {
            name: savename,
            tag: tag,
            autosave: autosave,
            number: num,
			hash: hash
        });
    } else {
        var hash = base64_encode(md5_string_utf8(str));
        var oldtag = indexsave.tag;
        var changetag = oldtag == tag;
        indexsave.name = savename;
        indexsave.tag = tag;
        indexsave.autosave = autosave;
		indexsave.hash = hash;
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
    
    otis_apply_save_changes(masterfile);
}

function otis_load_game(masterfile, filename) {
    otis_load_saves(masterfile);
    var str = global.saves[variable_struct_get(global.saves[0][1].saves, filename).number][1];
	if(md5_string_utf8(str) != base64_decode(variable_struct_get(global.saves[0][1].saves, filename).hash) and OTIS_CHECK_HASH)
		return "Hash error";
	else return str;
}

function otis_delete_save(masterfile, filename) {
    otis_load_saves(masterfile);
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
        
    otis_apply_save_changes(masterfile);
}

function otis_copy_save(masterfile, filename, suffix) {
    var str = otis_load_game(masterfile, filename);
    var indexsave = variable_struct_get(global.saves[0][1].saves, filename);
    
    var copyname = filename + " copy";
    while(variable_struct_get(global.saves[0][1].saves, copyname) != undefined)
        copyname += " copy";
    
    otis_save_game(str, copyname, indexsave.name + " " + suffix, indexsave.tag, indexsave.autosave, masterfile);
    
    return copyname;
}
