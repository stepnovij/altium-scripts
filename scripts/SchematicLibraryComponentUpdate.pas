// This is a script to update components in the SCHLIB
//
// Sets designators: 
// 1.   X=0, Y=100
// 2.   Autoposition On or Off (?)
//
// Sets comments: 
//
// 1.   X=0, Y=0
// 2.   Autoposition On or Off (?)
//
// Sets Pins to:
// 
// 1. Length to desired length
// 2. Name Position Mode = Custom (?)
// 3. Name Margin = Margin
// 4. Name Font = Desired Font Type and Size
// 5. Designator Margin = desired Margin
// 6. Designator Font = Desired Font Type and Size
// 
// Sets Rectangles to:
// 
// 1. Boarder Width = desired width
// 2. Color = desired color
// 3. Fill Color = desired color 
// 
// Sets Polygons to:
// 
// 1. Line Width = desired width
// 2. Color = desired color
// 3. Fill Color = desired color 
// 

// Function to get font id by font name and height
Function GetFontId(Name: TDynamicString, Height : Integer) : TFontID;
Var
    font_size : Integer;
    font_name : TDynamicString;
Begin
    font_size := Height;
    font_name := Name;
    Result    := SchServer.FontManager.GetFontID(font_size,
                                                 0,         // rotation
                                                 False,     // underline
                                                 False,     // italic
                                                 False,     // Bold
                                                 False,     // StrikeOut
                                                 font_name);
End;

// Update Library - Main Function
// Open Library before running the script
// Before running setup all the required parameters

Procedure UpdateLibrary;
Var
    CurrentLib         : ISch_Lib;
    LibraryIterator    : ISch_Iterator;
    PinIterator        : ISch_Iterator;
    RectangaleIterator : ISch_Iterator;
    PolygonIterator    : ISch_Iterator;
    DesignatorIterator : ISch_Iterator;
    CommentIterator    : ISch_Iterator;


    Pin                : ISch_Pin;
    R                  : ISch_Rectangle;
    P                  : ISch_Polygon;
    D                  : ISch_Designator;
    C                  : ISch_Comment;

    LibComp            : ISch_Component;

Begin
    If SchServer = Nil Then Exit;
    CurrentLib := SchServer.GetCurrentSchDocument;
    If CurrentLib = Nil Then Exit;
    If CurrentLib.ObjectID <> eSchLib Then
    Begin
         ShowError('Please open schematic library.');
         Exit;
    End;

    // get the library object for the library iterator.
    LibraryIterator := CurrentLib.SchLibIterator_Create;


    Try
        // find the aliases for the current library component.
        LibComp := LibraryIterator.FirstSchObject;
        While LibComp <> Nil Do
        Begin

            DesignatorIterator := LibComp.SchIterator_Create;
            DesignatorIterator.AddFilter_ObjectSet(MkSet(eDesignator));
            try
                        D := DesignatorIterator.FirstSchObject;
                        While D <> Nil Do
                        Begin
                                // Set X and Y position of designators to X=0, Y=100
                                D.Location := Point(MilsToCoord(0), MilsToCoord(100));
                                // Turn Autoposition On or Off
                                D.Autoposition := True;
                                // Set required font
                                D.FontID := GetFontId('Times New Roman', 10);
                                D := DesignatorIterator.NextSchObject;
                        End;
            Finally
                   LibComp.SchIterator_Destroy(DesignatorIterator);
            End;


            CommentIterator := LibComp.SchIterator_Create;
            CommentIterator.AddFilter_ObjectSet(MkSet(eParameter));
            try
                        C := CommentIterator.FirstSchObject;
                        While C <> Nil Do
                        Begin
                                // Set X and Y position of designators to X=0, Y=0
                                if C.Name = 'Comment' then begin
                                   C.Location := Point(MilsToCoord(0), MilsToCoord(0));
                                   C.Autoposition := True;
                                end;
                                // Turn Autoposition On or Off
                                C := CommentIterator.NextSchObject;
                        End;
            Finally
                   LibComp.SchIterator_Destroy(CommentIterator);
            End;


            PinIterator := LibComp.SchIterator_Create;
            PinIterator.AddFilter_ObjectSet(MkSet(ePin));
            try
                        Pin := PinIterator.FirstSchObject;
                        While Pin <> Nil Do
                        Begin
                             // Set Pin Length to desired length
                             Pin.PinLength := MilsToCoord(2000);
                             // Set Pin Name Position Mode to Custom
                             Pin.Name_PositionMode := 1;
                             // Set Pin Name Margin to desired Margin
                             Pin.Name_CustomPosition_Margin := 1;
                             // Set required font
                             Pin.Name_CustomFontID := GetFontId('Times New Roman', 11);
                             // Designator Custom Position Margin
                             Pin.Designator_CustomPosition_Margin := MilsToCoord(0);
                             // Designartor Custom Font
                             Pin.Designator_CustomFontId := GetFontId('Times New Roman', 11);
                             Pin := PinIterator.NextSchObject;
                        End;
            Finally
                   LibComp.SchIterator_Destroy(PinIterator);
            End;

            RectangaleIterator := LibComp.SchIterator_Create;
            RectangaleIterator.AddFilter_ObjectSet(MkSet(eRectangle));
            try
                        R := RectangaleIterator.FirstSchObject;
                        While R <> Nil Do
                        Begin
                             R.LineWidth := eSmall;
                             R.Color     := $00FFFF;    // YELLOW
                             R.AreaColor := $000000;    // BLACK
                             R.IsSolid   := True;
                             R := RectangaleIterator.NextSchObject;
                        End;
            Finally
                   LibComp.SchIterator_Destroy(RectangaleIterator);
            End;


            PolygonIterator := LibComp.SchIterator_Create;
            PolygonIterator.AddFilter_ObjectSet(MkSet(ePolygon));
            try
                        P := PolygonIterator.FirstSchObject;
                        While P <> Nil Do
                        Begin
                             P.LineWidth := eSmall;
                             P.Color     := $00FFFF;
                             P.AreaColor := $000000;
                             P           := PolygonIterator.NextSchObject;

                        End;
            Finally
                   LibComp.SchIterator_Destroy(PolygonIterator);
            End;
            // obtain the next schematic symbol in the library
            LibComp := LibraryIterator.NextSchObject;
        End;
    Finally
        // we are finished fetching symbols of the current library.
        CurrentLib.SchIterator_Destroy(LibraryIterator);
    End;
End;
