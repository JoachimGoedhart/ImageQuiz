# ImageQuiz

ImageQuiz is a shiny app that generates a multiple choice quiz. The quize tests the ability to identify images. Users can select the number of possible answers. The order of the answers is randomized. After a correct answer, a new image with possible answers is presented. In case of an incorrect answer, a notification appears to encourage the user to try again.

<img src="https://github.com/JoachimGoedhart/ImageQuiz/blob/master/ImageQuiz-Faces.png" alt="drawing" width="200"/>
<img src="https://github.com/JoachimGoedhart/ImageQuiz/blob/master/ImageQuiz-Flags.png" alt="drawing" width="200"/>

### How the app generates the quiz

Collections of images that are used for the quiz are taken from a subdirectory located in the map [www](https://github.com/JoachimGoedhart/ImageQuiz/tree/main/www).
The format of the images can be png, jpg, jpeg or gif

The name of the subdirectory reflects the collection and users can switch between these collections.
The names of the images (up till an underscore) are used to generate the (possible) answers. Different images can reflect the same object and will generate identical answers if their names (before the underscore, e.g. smiley_1.png, smiley_2.png) are the same.

### Credits

Fluorescence images from the "GFP-cDNA Localisation Project": [http://gfp-cdna.embl.de](http://gfp-cdna.embl.de)

Emoji and flag pictures from OpenMoji - the open-source emoji and icon project: [https://openmoji.org](https://openmoji.org)
  
ImageQuiz is created and maintained by Joachim Goedhart
[@joachimgoedhart](https://twitter.com/joachimgoedhart)