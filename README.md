# OTIS
**A save system for GameMaker** *(Organic Tag-Index-Save)*

## Install
Install *OTIS* with the `otis.yymps` package by creating a project, clicking on the *Tools* menu, selecting *Import Local Package*, and selecting the package file. The package contains the `otis` script.

## Usage

### *Saving / Loading*

#### `otis_save_game(str, filename, save name, tag, autosave, masterfile)`
Parameter|Type|Description
---|---|---
`str`|String|The string to save to the file
`filename`|String|The **permanent** name of the savefile
`savename`|String|The changeable name of the savefile *(should be the one displayed to the user)*
`tag`|String|A string used to categorize savefiles
`autosave`|Boolean|Whether the file being saved is an autosave or not
`masterfile`|String|The name of the masterfile containing all save data

***Returns:** N/A*

***Encodes and saves the string to the savefile which is contained in the masterfile.** Also contained in the masterfile is an index of all of the savefiles, which is appended to when a new savefile is created or metadata is updated and referenced when loading a specific savefile. If a new tag is being used, create an entry in the index for that tag. Then, the savefile's filename is added to the tag's listing.*

#### `otis_load_game(masterfile, filename)`
Parameter|Type|Description
---|---|---
`masterfile`|String|The name of the masterfile to load from
`filename`|String|The **permanent** name of the savefile to load

***Returns:** Contents of the specified save (String)*

***Loads and decodes the string from the savefile in the masterfile.** References the savefile index and receives the position in the list where the needed savefile is located, then decodes and returns that string.*

### *Manipulation*

#### `otis_delete_save(masterfile, filename)`
Parameter|Type|Description
---|---|---
`masterfile`|String|The name of the masterfile to load from
`filename`|String|The **permanent** name of the savefile to delete

***Returns:** N/A*

***Deletes the savefile from the masterfile.** Removes the to-be-deleted savefile itself, its index entry, and its name from its tag's listing. If its tag now has zero files associated with it, that tag is deleted from the index. All savefiles following the one deleted have their array indices decremented by one.*

#### `otis_copy_save(masterfile, filename, suffix)`
Parameter|Type|Description
---|---|---
`masterfile`|String|The name of the masterfile to load from
`filename`|String|The **permanent** name of the savefile to copy
`suffix`|String|The string to append to the end of the copied file's `savename`

***Returns:** The new copy's `filename`*

***Copies the savefile with the copy's name being appended with the suffix.** Adds the word "copy" to the filename until no other savefiles have that name, then calls the `save_game` function with the new filename and the savename appended with the suffix. All other parameters are the same as the original savefile's.*

## Hashing
You can protect savefiles from tampering with the `OTIS_CHECK_HASH` macro located in the `otis` script. If the hash check fails, `otis_load_game` will return the string `Hash error`. It is turned on by default.

## Credits
Created by [**Chase Peck**](https://chasepeck.com)

[***Organic Games LLC***](https://organic.games)
