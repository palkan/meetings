/**
 * User: VOVA
 * Date: 25.04.13
 * Time: 17:21
 */
package ru.teachbase.assets.fonts {
public class Pragmatica {



    [Embed(source="/fonts/PragmaticaC.otf",
            fontName = "PragmaticaC",
            mimeType = "application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="true")]

    public static const Normal:Class;

    [Embed(source="/fonts/PragmaticaC.otf",
            fontName = "PragmaticaC",
            mimeType = "application/x-font",
            fontWeight="normal",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="false")]

    public static const NormalN:Class;

    [Embed(source="/fonts/PragmaticaC-Bold.otf",
            fontName = "PragmaticaC",
            mimeType = "application/x-font",
            fontWeight="bold",
            fontStyle="normal",
            advancedAntiAliasing="true",
            embedAsCFF="true")]

    public static const Bold:Class;

    [Embed(source="/fonts/PragmaticaC-BoldItalic.otf",
            fontName = "PragmaticaC",
            mimeType = "application/x-font",
            fontWeight="bold",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="true")]

    public static const BoldItalic:Class;

    [Embed(source="/fonts/PragmaticaC-Italic.otf",
            fontName = "PragmaticaC",
            mimeType = "application/x-font",
            fontWeight="normal",
            fontStyle="italic",
            advancedAntiAliasing="true",
            embedAsCFF="true")]

    public static const Italic:Class;
}
}
