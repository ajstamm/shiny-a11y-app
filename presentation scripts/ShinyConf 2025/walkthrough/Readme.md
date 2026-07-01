# Simple example of making an app accessible

The "basic" app is based on the Appsalon example app.

The "final" app has correct aria text and keyboard navigation. It also has 
clearer user inputs and instructions for how to navigate the app.

# Note on accessibility for charts

For the "final" app to be fully accessible, plot data should also be available 
in a text based format such as a table. Coding and adding a reactive table 
based on bin size is beyond the scope of this demonstration. The texture and 
sound app has an example of a table like this. 

In general, any one element does not need to be fully accessible. However, all 
information should be fully accessible via one or more elements. Describing 
your content in paragraph text is always an option because *unformatted* text 
is fully accessible. Bear in mind that unformatted means "no text formatting". 
Screen readers generally ignore references to font color, font type, italics, 
and bold, so if you use font cues, do not rely *only* on font cues to convey 
information.
