#include <fstream>
#include <iostream>
#include <string.h>
#include <bitset>
#include <vector>
#include <sstream>
#include <map>
#include <cmath>

//Chris Hill

using namespace std;

/*Global variables associated with the system. */

int burst = 3;
int timeLeft = burst; //Time left for a program to execute before it is moved to back of the queue.
int currentTime = 0;
int memory = 2;
vector <string> finishedJobs; //A list of finished jobs.

/* File class.
 * No distinction between .p and .t aside from the extension field.
 * The contents of a .p file should always be empty.
 * The mem and cpu reqs for a .t file should always be zero.
 * IOreq is an optional pair of integers representing max IOtype
 * Memtype is the type of memory that the current program has. Physical and virtual.
 * If the memType is virtual then fetched represents whether or not the contents have been fetched for execution yet.
 * 2 means it has been fetched. Any less means it has not.*/


class file
{
public:

    string name;
    string extension;
    string contents;
    int cpuReq;
    int memReq;
    int cpuReqLeft;
    pair <int, int> IOreq;
    string memType;
    int timeWaiting;
    int fetched;

    file()
    {
        name = "default";
        extension = "n"; // Extension must be manually set.
        contents = "";
        cpuReq = 0;
        memReq = 0;
        cpuReqLeft = cpuReq;
        IOreq.first = 0;
        IOreq.second = 0;
        memType = "none"; //none, physical, virtual.
        timeWaiting - 0;
        fetched = 0;
    }
};

file currentProgram;
vector <file> IOfiles;

/* Directory object.
 * size is the number of files + directories in the directory.
 * Files are all the files in the directory stored as a dictionary. Key is the name of the file, and value is the actual file.
 * Chose map to easier access a specific  file in the shell.
 * Directories are all the directories in the directory. Same implementation as files just with directories. */

class directory
{
public:

    string name;
    map <string, file> files;
    map <string, directory> directories;
    int size;

    directory()
    {
        name = "default";
        map <string, file> files;
        map <string, directory> directories;
        size = 0;
    }

};

/* Linked list. Used to keep track of previous directory, so as to allow for changing directories. */

class node
{
public:

    directory data;
    node* previous;

};


/* https://www.geeksforgeeks.org/circular-queue-set-1-introduction-array-implementation * /
 * Stolen from here. I feel no shame as it's a common data structure. */

class queue
{
public:

    int front;
    int back;
    int size;
    file *arr;

    queue(int s)
    {
        front = back = -1;
        size = s;
        arr = new file[s];
    }

    void enQueue(file value);
    file deQueue();
    void displayQueue();
    bool isEmpty();

};

/*Takes in a file and adds it to the back of the Queue. */
/* param: file  returns: void */

void queue::enQueue(file value)
{
    if ((front == 0 && back == size-1) ||
        (back == (front-1)%(size-1)))
    {
        printf("\nQueue is Full");
        return;
    }

    else if (front == -1) /* Insert First Element */
    {
        front = back = 0;
        arr[back] = value;
    }

    else if (back == size-1 && front != 0)
    {
        back = 0;
        arr[back] = value;
    }

    else
    {
        back++;
        arr[back] = value;
    }
}

// Removes the first element of the queue and returns it.
// params: None returns: file

file queue::deQueue()
{
    file emptyFile;

    if (front == -1)
    {
        cout << "The queue is Empty. \n";
        return emptyFile;
    }

    file data = arr[front];
    arr[front] = emptyFile;
    if (front == back)
    {
        front = -1;
        back = -1;
    }
    else if (front == size-1)
        front = 0;
    else
        front++;

    return data;
}

//Prints out the elements in the q for all to see.
//params: none  returns: void

void queue::displayQueue()
{
    if (front == -1)
    {
        cout << "Queue is Empty \n";
        return;
    }
    cout << "Programs in queue are: " << "\n";
    if (back >= front)
    {
        for (int i = front; i <= back; i++) {
            cout << arr[i].name << " Time left equals: " << arr[i].cpuReqLeft
            << " using " << arr[i].memReq << " unit of memory of " << "type " << arr[i].memType << "\n";
        }
        cout << "\n";
    }
    else
    {
        for (int i = front; i < size; i++)
            cout << arr[i].name;

        for (int i = 0; i <= back; i++)
            cout << arr[i].name;
    }
}

//Checks if the queue is empty.
//params: none  returns: boolean.

bool queue::isEmpty()
{
    if (front == -1){
        return true;
    }
    else {
        return false;
    }
}

//This is the maximum size of the queue.

queue q(10);

// params: a string of binary of type string
// returns:   ascii string of type string.
// See main function for more details.

string binaryToString (string data);

// params: a string of binary of type string
// returns: ascii string of type string.
// See main function for more details.

string readName (string data);

// params: dir of type directory, lines of type string vector, place of type integer
// returns: pair of type directory and integer.
// See main function for more details.

pair <directory, int> readDirectory (directory dir, vector <string> lines, int place);

// params: a dir of type directory  
// returns: void 
// See main function for more details.

void ls (directory dir);

// params: a string filename of type string 
// returns: a string of binary of type string 
// See main function for more details.

string filenameToBin(string filename);

// params: a fileToWrite of type file  
// returns: vector of strings  
// See main function for more details.

vector <string> fileWrite(file fileToWrite);

// params: a dirToWrite of type directory  
// returns: a vector of strings  
// See main function for more details.

vector <string> dirWrite(directory dir);

// params: a binary string of type string  
// returns: a decimal number of type integer  
// See main function for more details.

int bin2dec(const char* str);

// params: an amount of steps of type int  
// returns: void  
// See main function for more details.

void step (int steps); 

int main(int argc, char** argv) {

    string fileSystemFilename = argv[1]; //Get filename from command line.
    ifstream inFile;
    string word;
    vector<string> fileContents;

    inFile.open(fileSystemFilename.c_str());
   
   while (inFile >> word) { //Add contents of binary file system file to vector.
        fileContents.push_back(word); 
    }

    directory rootdir;
    rootdir.name = "root.d";
    rootdir.size = 0;

    if (fileContents.size() > 0) {  //If this file is a valid file system, then we make our root directory file from it.
        int place = 2;
        rootdir = readDirectory(rootdir, fileContents, place).first;
    } else { //Skip that and move on to the commands below.

    }
	
    /* Setting up the linked list. */

    node *tail;
    node *n;

    n = new node;
    n->data = rootdir;
    n->previous = NULL;
    tail = n;

    string input;
	
    while (cout <<"EnterCommand>" && getline(cin, input)) { // Loops until we tell it to end.
		
		if (!input.empty() && input[input.size() - 1] == '\r'){ //When you move over a text file from Windows to UNIX it has these return things... messed with RUCS.
			input.erase(input.size() - 1);
		}
					
		input = input.substr(input.find_first_not_of(" "), input.length()); //Strip input of all left white space.
        //Divide the string into command and argument.

        int firstSpaceIndex = input.find_first_of(" ");
        int anyOtherChars;

        if (firstSpaceIndex != -1) {
            anyOtherChars = input.substr(firstSpaceIndex, input.length() - firstSpaceIndex).find_first_not_of(" ");
        }
		
        string command = input.substr(0, firstSpaceIndex);
		//cout << "command is: !" << command << "!\n";
        string argument = "";
        string secondHalf = "";
	

        if (firstSpaceIndex != -1 && anyOtherChars != -1) { // If there is no space or other characters after
            // the command we know that it's a one argument command like ls.

            secondHalf = input.substr(firstSpaceIndex,
                                      input.length() - firstSpaceIndex); //Argument equals the second half

            //Trim the second half.

            argument = secondHalf.substr(secondHalf.find_first_not_of(" "), secondHalf.length());
            int secondSpaceIndex = argument.find_first_of(" ");

            if (secondSpaceIndex != -1) {
                argument = argument.substr(0, secondSpaceIndex);
            }
        }

        /* Starts the command branch.  */

        if (command == "ls") {
            ls(tail->data);
        } else if (command == "showQ") {
            cout << "Running job " << currentProgram.name << " has " << currentProgram.cpuReqLeft << " CPUreq left and is using "
                 << currentProgram.memReq << " resources. \n";
            q.displayQueue();
        } else if (command == "pwd") {

            /* We don't want to interfere with the main linked list so we just copy it and do operations on that. */

            node *cpy = new node;
            cpy = tail;
            string path = "";
            vector<string> paths;

            int first = 1;

            /* We go back until the previous node equals null so we know we reached the root
             * Then we add the name of the current dir to a list of dirs.
             * Then we print it in reverse order to get our pwd */

            while (cpy != NULL) {
                paths.push_back(cpy->data.name.substr(0, cpy->data.name.length() - 2));
                cpy = cpy->previous;
            }
            for (int i = paths.size() - 1; i >= 0; i--) {
                if (first == 0) {
                    path = path + "/" + paths.at(i);
                } else {
                    first = 0;
                    path = path + paths.at(i);
                }
            }
            cout << "Current directory is " + path + "\n";
        } else if (command == "cd") {
            if (argument == "..") {
                if (tail->previous == NULL) { //Does nothing if we're in the root directory.
                } else {

                    /* Just some linked list operations to get the previous directory */

                    tail->previous->data.directories[tail->data.name] = tail->data;
                    tail = tail->previous;
                }
            } else {
                if (tail->data.directories.count(argument + ".d") ==
                    0) {  // All files need the extension as part of the
                    // file name for reading purposes.
                    cout << "Error not a valid directory. \n";
                } else { //If the argument wasn't ".." then we know to try to change to the directory specified.
                    // This is why I used a dictionary. It's easier to find the directory in question this way.
                    n = new node;
                    n->data = tail->data.directories.at(argument + ".d");
                    n->previous = tail;
                    tail = n;
                }
            }
        } else if (command == "mkdir") {
            directory newDir;
            newDir.name =
                    argument + ".d"; // All files need the extension as part of the file name for reading purposes.
            tail->data.directories[newDir.name] = newDir;
            tail->data.size = tail->data.size + 1;
        } else if (command == "createTextFile") {
            file newfile;
            string contents;
            string filename;

            if (argument == "") { // If there is no argument, prompts for a filename.
                cout << "Enter filename>";
                getline(cin, filename);
                filename = filename + ".t";
                cout << "Enter file contents>";
                getline(cin, contents);
            } else {
                filename = argument + ".t";
                cout << "Enter file contents>";
                getline(cin, contents);
            }

            newfile.name = filename;
            newfile.contents = contents;
            newfile.extension = "t";
            tail->data.files[newfile.name] = newfile;
            tail->data.size = tail->data.size + 1; //Update the size since a new file has been added.
        } else if (command == "addProgram") {

			/* All of this is to get addProgram to actually addPrograms with both 2 and 4 arguments. */
		
            secondHalf = secondHalf.substr(secondHalf.find_first_not_of(" "), secondHalf.length()); //This is a callback from above when we were getting the cosmmand...that's where secondHalf is from

            int firstpSpaceIndex = secondHalf.find_first_of(" ");
            string programName = secondHalf.substr(secondHalf.find_first_not_of(" "), firstpSpaceIndex);

            string secondFifth = secondHalf.substr(firstpSpaceIndex + 1, secondHalf.length());
            int secondpSpaceIndex = secondFifth.find_first_of(" ");
            string cpuReq = secondFifth.substr(secondFifth.find_first_not_of(" "), secondpSpaceIndex);

            string thirdFifth = secondFifth.substr(secondpSpaceIndex + 1, secondFifth.length());
            int thirdpSpaceIndex = thirdFifth.find_first_of(" ");
            string memReq = thirdFifth.substr(thirdFifth.find_first_not_of(" "), thirdpSpaceIndex);

            if (thirdFifth.length() - memReq.length() == 0) { //If there are no other arguments. Add it to the queue.
                file newfile;
                newfile.extension = "p";
                newfile.name = programName + ".p";
                stringstream stream(cpuReq);
                stream >> newfile.cpuReq;
                newfile.cpuReqLeft = newfile.cpuReq;
                stringstream stream2(memReq);
                stream2 >> newfile.memReq;
                tail->data.files[newfile.name] = newfile;
                tail->data.size = tail->data.size + 1; //Update the size since a new file has been added.
            } else { //We have IOreq arguments to handle.

                string fourthFifth = thirdFifth.substr(thirdpSpaceIndex + 1, thirdFifth.length());
                int fourthpSpaceIndex = fourthFifth.find_first_of(" ");
                string pair1 = fourthFifth.substr(fourthFifth.find_first_not_of(" "), fourthpSpaceIndex);

                string fifthFifth = fourthFifth.substr(thirdpSpaceIndex + 1, thirdFifth.length());
                int fifthpSpaceIndex = fifthFifth.find_first_of(" ");
                string pair2 = fifthFifth.substr(fifthFifth.find_first_not_of(" "), fifthpSpaceIndex);

				// Finally add all of this to the directory.
				
                file newfile;
                newfile.extension = "p";
                newfile.name = programName + ".p";
                stringstream stream(cpuReq);
                stream >> newfile.cpuReq;
                newfile.cpuReqLeft = newfile.cpuReq;
                stringstream stream2(memReq);
                stream2 >> newfile.memReq;
                stringstream stream3(pair1);
                stringstream stream4(pair2);

                stream3 >> newfile.IOreq.first;
                stream4 >> newfile.IOreq.second;

                tail->data.files[newfile.name] = newfile;
                tail->data.size = tail->data.size + 1;
            }
        } else if (command == "cat") { //Prints out of the contents of a text file.
            cout << tail->data.files.at(argument + ".t").contents + "\n";
        } else if (command == "run") { //Runs what is in the queue until all programs are finished. Calls step to do this. 
            vector <string> emptyJobs;

            cout << "Current time <" << currentTime << "> \n";
            cout << "Running job " << currentProgram.name << " has " << timeLeft << " time left and is using "
            << currentProgram.memReq << " resources. \n";

            while (currentProgram.extension != "n" || !q.isEmpty() || IOfiles.size() > 0) { // If there is a current program, there is stuff in the queue, or IOFiles to run.  
                step(1);
            }

            currentTime = 0; //Reset everything back so if we run something else, it'll be accurate. 
            finishedJobs = emptyJobs; 

        } else if (command == "start") {

            if (tail->data.files.count(argument + ".p") == 1) { //If there is a program with this name in the directory.

                if(currentProgram.extension == "n" && IOfiles.size() < 1 && q.isEmpty() ) { //If there are no other programs then we set this program to the current program.
                    currentProgram = tail->data.files.at(argument + ".p");
                    memory = memory - currentProgram.memReq; //Be sure to alter the memory. 
                }
                else {
                    if (memory - tail->data.files.at(argument + ".p").memReq < 0) { // If we have to swap.
                        int swapPos = -1; //Position of swap for virtual memory. 
                        int minTimewaiting = 99999999; // The minimum amount of time spent waiting to be run. This determines what we swap.     

                        for (int i = 0; i < q.size; i++) { //We loop through the queue, and check if...
                            if (q.arr[i].timeWaiting <= minTimewaiting && q.arr[i].memType == "physical") { //If the time waiting  of the item in the queue is less than the minimum we set it to the minimum and then we adjust the swap position.
                                swapPos = i;
                                minTimewaiting = q.arr[i].timeWaiting;
                            }
                        }
                        tail->data.files.at(argument + ".p").memType = "physical";
                        q.enQueue(tail->data.files.at(argument + ".p")); //Add it to the q.
                        q.arr[swapPos].memType = "virtual";
                    } else { //If we don't have to swap we just add it to the queue.
                        tail->data.files.at(argument + ".p").memType = "physical";
                        q.enQueue(tail->data.files.at(argument + ".p"));
                        memory = memory - tail->data.files.at(argument + ".p").memReq;
                    }
                }
            } else {
                cout << "No such program " << argument+".p" << "exists. \n";
            }
        } else if (command == "step") { //Calls the step function.
            int steps;
            stringstream stream(argument); //Amount of steps
            stream >> steps;
            step(steps);
        } else if (command == "setBurst") { // Sets the burst to whatever the argument is.
            stringstream stream(argument);
            stream >> burst;
        } else if (command == "setMemory") { //Sets the memory to whatever the argument is.. 
            stringstream stream(argument);
            stream >> memory;
        } else if (command == "getMemory") {
            cout << "The amount of memory is: " << memory << "\n"; //Shows the current memory.
        } else if (command == "help") { //Shows a list of all valid commands..

            cout << "List of valid commands: \n";
            cout << "cat \n";
            cout << "cd \n";
            cout << "createTextFile \n";
            cout << "getMemory \n";
            cout << "help \n";
            cout << "ls \n";
            cout << "mkdir \n";
            cout << "mkdir \n";
            cout << "pwd \n";
            cout << "run \n";
            cout << "setBurst \n";
            cout << "setMemory \n";
            cout << "showQ \n";
            cout << "start \n";
            cout << "step \n";
            cout << "\n";
			
		}
		else if (command == "Quit") {
			break;
			} else {
          cout << "Invalid command! \n";
        }
    }

        /*We are finished with our commands, now we must write the final directory to the .bin file.
         * We need to go to the head of the linked list which is our root directory. We will be calling
         * our write method on that. */

        while (tail->previous != NULL) {
            tail->previous->data.directories[tail->data.name] = tail->data;
            tail = tail->previous;
        }

        /*Setting up for the directory write. */

        map<string, directory> directories = tail->data.directories;
        map<string, directory>::iterator itr;

        //Updates the directory size now that all operations are done.

        tail->data.size = tail->data.directories.size() + tail->data.files.size();
        ofstream outfile;
//    string f2 ="man.bin";
        outfile.open(fileSystemFilename.c_str());

        vector<string> linesToWrite;
        linesToWrite = dirWrite(tail->data);

        for (int i = 0; i < linesToWrite.size(); i++) {
            outfile << linesToWrite.at(i) << "\n";
        }
        return 0;
    }

/* I don't remember writing this so I probably copy pasted this from somewhere else, probably StackOverflow. +/
 * Converts a binary string to it's ascii equivalent. */
 // params: a string of binary of type string
 // returns: ascii string of type string.

string binaryToString (string str) {

    char parsed = 0;
    for (int i = 0; i < 8; i++) {
        if (str[i] == '1') {
            parsed |= 1 << (7 - i);
        }
    }
    string answer (1,parsed);
    return answer;

}

/* I can't remember writing this so like the above, it is probably taken from somewhere online. I do think I modified
 * it.*/
 // params: a string of binary of type string
 // returns: ascii string of type string.


string readName (string line) {
    string output;
    for (int i = 0; i < line.length(); i = i + 8) {
        bitset<8> bits (string(line.substr(i,8)));
        if(bits.to_string().compare("00000000") != 0) {
            char c = char(bits.to_ulong());
            output += c;
        }
    }
    return output;
}

/* This is a function to read a .bin file and store it in a directory file. */
/* Returns a directory, the completely made object, and an integer representing the current place. (See below)
/* Dir is the directory to read. If you are first running this, you should just run it on an empty directory. */
/* The lines field is a list of all the lines in the binary file system in sequential order. */
/* Place is the index or line number. Position. Because we are recursively calling readDirectory to deal with nested
 * directories, we needed a way to transfer the line position after the recursive call is done.*/
 // params: dir of type directory, lines of type string vector, place of type integer
 // returns: pair of type directory and integer.

pair <directory, int> readDirectory (directory dir, vector <string> lines, int place) {

    while(lines.at(place) !="00000011"){ // This is the end of directory character. It runs until it reaches that then returns.

        if(lines.at(place).length() > 8){ // Basic error checking. This condition shouldn't really ever be true.

            string extension = lines.at(place).substr(72,8); //Gets the extension of the next line. Then decides what to do based on the extension.

            if(extension == "01110000") { // This is the ascii value of p
                file program; // Creates a file that will be added to the returned directory.
                program.extension = "p"; // Sets it to p for program.
                program.name = readName(lines.at(place).substr(0,80)); //Gets the name, increments to get the required values.
                place = place + 1;
                program.cpuReq = bin2dec(lines.at(place).c_str());
                program.cpuReqLeft = program.cpuReq;
                place = place + 1;
                program.memReq = bin2dec(lines.at(place).c_str());
                place = place + 1;
                program.IOreq.first = bin2dec(lines.at(place).c_str());
                place = place + 1;
                program.IOreq.second = bin2dec(lines.at(place).c_str());

                dir.files[program.name]= program;
                place = place + 1;
            }
            else if(extension == "01110100") { // This is the ascii bin value of t.

                file textFile; // Same as above except with a textfile instead.
                textFile.extension ="t";
                textFile.name = readName(lines.at(place).substr(0,80));
                place = place + 1;
                string contents;

                // Gets the contents of the text file. One character at a time.

                for (int i = 0; i < lines.at(place).length(); i = i + 8){
                    contents = contents + binaryToString(lines.at(place).substr(i,8));
                }
                textFile.contents = contents;
                dir.files[textFile.name]= textFile;
                place = place + 1;
            }
            else if(extension == "01100100") { // ASCII bin value of d.

                directory dir2; // Creates a directory and reads its info from the lines.
                dir2.name = readName(lines.at(place).substr(0,80));

                place = place + 1;
                dir2.size = bin2dec(lines.at(place).c_str());

                place = place + 1;
                pair <directory, int> results = readDirectory(dir2,lines,place); //Recursive call to handle nested directories.

                dir2 = results.first;

                dir.directories[dir2.name] = dir2;

                place = results.second + 1;
            }
        }
    }
    pair <directory, int> answer;
    answer.first = dir;
    answer.second = place;
    return answer;
}


/* This entire function was copy pasted from stack overflow. Then modified.
 * The pattern here is that most binary functions (that often have built in functions in other languages)
 * are not written by me. */
/* Converts a binary number to a decimal number. */
// params: a binary string of type string  
// returns: a decimal number of type integer

int bin2dec(const char* str) {
    int n = 0;
    int size = strlen(str) - 1;
    int count = 0;
    while ( *str != '\0' ) {
        if ( *str == '1' )
            n = n + pow(2, size - count );
        count++;
        str++;
    }
    return n;
}

/* Returns the .bin file representation of a directory. Should be called on the ROOT directory to handle the whole thing.
 * Returns a list of strings whose order is the order the binary file should be written. Doesn't actually write. */
 // params: a dirToWrite of type directory  
 // returns: a vector of strings  

vector <string> dirWrite(directory dir) {

    vector <string> toWrite;
    bitset<8> sizeBit(dir.size);

    toWrite.push_back(filenameToBin(dir.name));
    toWrite.push_back(sizeBit.to_string());

    map<string, file>::iterator itr;

    /* Write the files. */

    for (itr = dir.files.begin(); itr != dir.files.end(); itr++) {
        vector <string> fileText;
        fileText = fileWrite(itr->second);

        for(int j = 0; j < fileText.size();j++){
            toWrite.push_back(fileText.at(j));
        }
    }
    map<string, directory>::iterator itr2;

    /* Writes the directories. */

    if (!dir.directories.empty()) {
        for (itr2 = dir.directories.begin(); itr2 != dir.directories.end(); itr2++) {
            vector <string> directoryText;
            directoryText = dirWrite(itr2->second);

            for (int i = 0; i < directoryText.size(); i++){
                toWrite.push_back(directoryText.at(i));
            }
        }
    }
    toWrite.push_back("00000011");
    return toWrite;
}

/* Just prints out everything that is contained in the directory. */
/* When it's called it's called on the tail of the linked list. */
// params: a dir of type directory  
// returns: void 

void ls (directory dir) {
    map <string, directory> directories = dir.directories;
    map <string, directory> :: iterator itr;

    cout << "Current Directory: " + dir.name.substr(0,dir.name.length()-2) + "\n";

    map <string, file> files = dir.files;
    map <string, file> :: iterator itr2;

    for (itr2 = files.begin(); itr2 != files.end(); itr2++){
        cout << "Filename: " + itr2->first.substr(0,itr2->first.length()-2) + " Type: " + itr2->second.extension + "\n";
    }

    for (itr = directories.begin(); itr != directories.end(); itr++){
        cout << "Directory Name: " + itr->first.substr(0,itr->first.length()-2) + "\n";
    }
}

/* Write a filename to binary. It's more complicated because of the null terminators.*/
// params: a string filename of type string 
// returns: a string of binary of type string 

string filenameToBin(string filename) {
    string result;
    int length = filename.length();
    char char_array[length + 1];
    strcpy(char_array, filename.c_str());

    //Stores all of the non file extension characters in a string called result.

    for (int i = 0; i < length - 2; i++) {

        char letter = char_array[i];
        int decLetter = int(letter);
        bitset<8> binLetter(decLetter);
        result = result + binLetter.to_string();
    }

    // Adds null terminators to result as necessary.

    for (int j = 0; j < (10 - length); j++) {
        result = result + "00000000";
    }

    // Adds the file extension and then finally the null terminator to result.

    char letter = char_array[length-2];
    int decLetter = int(letter);
    bitset<8> binLetter(decLetter);
    result = result + binLetter.to_string();

    letter = char_array[length-1];
    decLetter = int(letter);
    bitset<8> binLetter2(decLetter);
    result = result + binLetter2.to_string();
    result = result + "00000000";

    return result;

}

/* Converts a string to binary ASCII values. */
	//params: contents of type string
	//returns: string 

string stringToBin(string contents) {
    string result;
    int length = contents.length();
    char char_array[length+1];
    strcpy (char_array, contents.c_str());

    for(int i = 0; i < length; i++) {

        char letter = char_array[i];
        int decLetter = int(letter);
        bitset<8> binLetter(decLetter);
        result = result + binLetter.to_string();

    }

    return result;
}

/* Writes the file contents of a file to a list of strings. It's part of the directoryWrite function,
 * used to write a binary file system. */
 // params: a fileToWrite of type file  
 // returns: vector of strings  

vector <string> fileWrite(file fileToWrite) {

    vector <string> toWrite;
    toWrite.push_back(filenameToBin(fileToWrite.name));

    if (fileToWrite.extension.compare("t") == 0) { //Text branch.
        toWrite.push_back(stringToBin(fileToWrite.contents));
    }
    else if (fileToWrite.extension.compare("p") == 0) { //Program branch.
        bitset<8> cpuBit(fileToWrite.cpuReq);
        bitset<8> memBit(fileToWrite.memReq);
        bitset<8> pair1Bit(fileToWrite.IOreq.first);
        bitset<8> pair2Bit(fileToWrite.IOreq.second);
        toWrite.push_back(cpuBit.to_string());
        toWrite.push_back(memBit.to_string());
        toWrite.push_back(pair1Bit.to_string());
        toWrite.push_back(pair2Bit.to_string());

    } else {
        cout << "The file extension of " + fileToWrite.name + " is " + fileToWrite.extension;
        cout << "Error not a valid file extension. You should not be seeing this."; //Error checked in an earlier func.
    }
    return toWrite;
}

//Steps one step into the program simulation.
//params: integer of type steps
//returns: void      

void step (int steps) { //

    if(steps < 1) {
        cout << "Error not a valid number of steps! Must be greater than 0. \n";
    }

    if (q.front == -1 && currentProgram.extension =="n" ) {
        cout << "No running program or program in queue. \n";
    }

    file emptyFile;

    for (int i = 0; i < steps; i++) {

        if(currentProgram.extension == "n"){ // If there is no current program.
            if(q.isEmpty()){ //If there is no current program and the queue is also empty.
                if(IOfiles.size() < 1) { //If there are no files waiting for IO.
                    currentTime = 0; //There is nothing else to do. End it.
                    vector <string> emptyJobsList;
                    finishedJobs = emptyJobsList;
                    cout << "Simulation complete.";
                    break;
                } // Else instead there are IOfiles.
                else {
                   // cout << "Lowering " << IOfiles.at(0).name << "'s IO wait time from" << IOfiles.at(0).IOreq.first;
                    IOfiles.at(0).IOreq.second = IOfiles.at(0).IOreq.second - 1;
                    currentTime = currentTime + 1;

                    for(int i = 0; i < IOfiles.size(); i++) {
                        IOfiles.at(i).timeWaiting = IOfiles.at(i).timeWaiting + 1;
                    }

                  //  cout << " to " << IOfiles.at(0).IOreq.first << ". \n";
                  //  cout <<"<" << currentTime << ">";
                    if(IOfiles.at(0).IOreq.second == 0) { // If after waiting the IOfile is ready.
                        IOfiles.at(0).IOreq.first = 0;
                   //     cout << "Setting " << IOfiles.at(0).name << "'s IO required time to zero. \n";
                        q.enQueue(IOfiles.at(0));
                    //    cout << "Adding " << IOfiles.at(0).name << " to the back of the queue. \n";
                        IOfiles.erase(IOfiles.begin());
                        continue;
                    }
                    else { //If after waiting it's not ready.
                    //    cout << "Waited for IO for one time unit. \n";
                        continue;
                    }
                }
            }
            else { //If there is no current program and instead the queue is not empty.
               // cout << "Setting " << q.arr[q.front].name << " to the current program instead of empty file. \n";
                currentProgram = q.arr[q.front];
                currentProgram.timeWaiting = 0;
                q.deQueue();
                continue;
            }
        }
        else { //If instead there is a current program.
            if(currentProgram.IOreq.first != 0) { //If there is a current program and it does need IO.
                if(q.isEmpty()){ //If there is a current program, it does need IO, and the queue is empty.
                    IOfiles.push_back(currentProgram);
               //     cout << "Adding " << currentProgram.name << " to the IOProgram list because it needs IO. \n";
                //    cout << "It will be back in " << currentProgram.IOreq.second << " time units. \n";
                    currentProgram = emptyFile;
              //      cout << "Set currentProgram to empty file because the queue is empty. \n";
                    continue;
                }
                else{ // If there is a current program, it needs IO, and instead the queue is not empty.
                    currentProgram.cpuReqLeft = currentProgram.cpuReqLeft -1;
                    currentTime = currentTime + 1;
                    IOfiles.push_back(currentProgram);
              //      cout << "Adding " << currentProgram.name << " to the IOProgram list because it needs IO. \n";
                    currentProgram = q.arr[q.front];
                    currentProgram.timeWaiting = 0;
              //      cout << "Set the current program to the first item in the queue " << q.arr[q.front].name << "\n";
                    q.deQueue();
                    continue;
                }
            }
            else { //If instead there is a current program and it does not need IO.

                if(currentProgram.cpuReqLeft == 0){ //If there is a current program that does not need IO and needs no CPU time.
                 //   cout << "Current program " << currentProgram.name << " does not need CPU time. It has finished. \n";
                    timeLeft = burst;
                   // cout << "Time left now equals " << timeLeft << "\n";
                    stringstream cpustream;
                    stringstream timeStream;
                    cpustream << currentProgram.cpuReq;
                    timeStream << currentTime;
                    string finishedString = currentProgram.name + " " + cpustream.str() + " " + timeStream.str() + "\n";
                    finishedJobs.push_back(finishedString);
                    memory = memory + currentProgram.memReq;


                    if(q.isEmpty()) { //If the queue is empty after this job has finished.
                        currentProgram = emptyFile;
                        cout << "<"<< currentTime << ">" << "\n";
                        cout << "Running job " << currentProgram.name << " has " << currentProgram.cpuReqLeft
                             << " units left and is using " << currentProgram.memReq << " memory. \n ";
                        q.displayQueue();
                        cout << "Finished jobs are :\n";
                        for (int i = 0; i < finishedJobs.size(); i++) {
                            cout << finishedJobs.at(i);
                        }
                        cout << "\n";

                        //          cout << "The current program is now an empty file. \n";
                        if(IOfiles.size() < 1) { //If the queue is empty after the job has finished and there are no files waiting on IO.
               //             cout << "No files waiting on IO, continue loop. \n";
                            continue;
                        }
                    }
                    else{ //If instead the queue is not empty after this job has finished.

                        currentProgram = q.arr[q.front];
                        currentProgram.timeWaiting = 0;
                        q.deQueue();

                        cout << "<"<< currentTime << ">" << "\n";
                        cout << "Running job " << currentProgram.name << " has " << currentProgram.cpuReqLeft
                             << " units left and is using " << currentProgram.memReq << " memory. \n ";
                        q.displayQueue();
                        cout << "Finished jobs are :\n";
                        for (int i = 0; i < finishedJobs.size(); i++) {
                            cout << finishedJobs.at(i);
                        }
                        cout << "\n";

                        continue; }

                }
                else { //If instead the current program does need CPU time.
                    if(timeLeft == 0) { //If the time left is zero.
                      //  cout << currentProgram.name << " has run out of time adding it to the queue. \n";

                        if(currentProgram.memType == "virtual") {
                            currentProgram.fetched = 0;
                        }

                        q.enQueue(currentProgram);
                        currentProgram = q.arr[q.front];
                        currentProgram.timeWaiting = 0;
                        q.deQueue();
						
						//We set a new current program so display the state. 

                        cout << "<"<< currentTime << ">" << "\n";
                        cout << "Running job " << currentProgram.name << " has " << currentProgram.cpuReqLeft
                             << " units left and is using " << currentProgram.memReq << " memory. \n ";
                        q.displayQueue();
                        cout << "Finished jobs are: \n";
                        for (int i = 0; i < finishedJobs.size(); i++) {
                            cout << finishedJobs.at(i);
                        }
                        cout << "\n";

                        timeLeft = burst;
                   //     cout << "Continuing in the loop. \n";
                        continue;
                    }
                    else{ //If instead the time left is not zero.
                        if(currentProgram.memType == "virtual") { //Have to fetch the data before it can be executed.
                            if(currentProgram.fetched != 2) {
                            timeLeft = timeLeft - 1;
                            currentTime = currentTime + 1;
                            currentProgram.fetched = currentProgram.fetched + 1;
                            continue;
                            }
                        }
                    //    cout << "cpuReqLeft of " << currentProgram.name << " has been reduced from "
//                             << currentProgram.cpuReqLeft << "to ";
                        currentProgram.cpuReqLeft = currentProgram.cpuReqLeft - 1;
                  //      cout << currentProgram.cpuReqLeft <<  "\n";

                 //       cout << "timeleft = " << timeLeft << "\n";
                        timeLeft = timeLeft - 1;
                        currentTime = currentTime + 1;

                        for(int i = 0; i < q.size; i++) { //We increase the time waited for all items in the queue. 
                            q.arr[i].timeWaiting = q.arr[i].timeWaiting + 1;
                        }

                        for(int i = 0; i < IOfiles.size(); i++) { //Increase time waited for IOFiles.
                            IOfiles.at(i).timeWaiting = IOfiles.at(i).timeWaiting + 1;
                        }

                     //  cout << "<"<<currentTime<<"> \n";
                     //    cout << currentProgram.name << " has had its cpuReq decreased by 1 to " << currentProgram.cpuReqLeft << "\n";

                        if(currentProgram.memType == "virtual") {
                            if(memory - currentProgram.memReq >=0) {
                                currentProgram.memType = "physical";
                                memory = memory - currentProgram.memReq;
                            }
                        }

                        if(IOfiles.size() > 0) { //If there are IOfiles

                            if(IOfiles.at(0).IOreq.second == 0) { // If after waiting the IOfile is ready.
                          //      cout << IOfiles.at(0).name << "Is ready and no longer has to wait. \n";
                                IOfiles.at(0).IOreq.first = 0;
                                q.enQueue(IOfiles.at(0));
                           //     cout << "Added " << IOfiles.at(0).name << " to the back of the queue. \n";
                                IOfiles.erase(IOfiles.begin());
                                continue;
                            }
                            else { //If after waiting it's not ready.
                      //          cout << "IO file " << IOfiles.at(0).name << " is still not ready. Continuing loop. \n";
                            }

                       //     cout << "Lowering " << IOfiles.at(0).name << "'s IO wait time from" << IOfiles.at(0).IOreq.second;
                            IOfiles.at(0).IOreq.second = IOfiles.at(0).IOreq.second - 1;
                       //     cout << " to " << IOfiles.at(0).IOreq.second << ". \n";
                        } else { //If the IOFiles are empty.
                            continue;
                        }
                    //    cout << "Continuing in the loop. \n";
                        continue;
                    }
                }
            }
        }
    }
}