/*
 * Copyright (c) 2023 DittoLive.
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * This project and source code may use libraries or frameworks that are
 * released under various Open-Source licenses. Use of those libraries and
 * frameworks are governed by their own individual licenses.
 *
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package live.dittolive.chat.conversation

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.sp

// Regex containing the syntax tokens
val symbolPattern by lazy {
    Regex("""(https?://[^\s\t\n]+)|(`[^`]+`)|(@\w+)|(\*[\w]+\*)|(_[\w]+_)|(~[\w]+~)""")
}

// Accepted annotations for the ClickableTextWrapper
enum class SymbolAnnotationType {
    PERSON, LINK
}
typealias StringAnnotation = AnnotatedString.Range<String>
// Pair returning styled content and annotation for ClickableText when matching syntax token
typealias SymbolAnnotation = Pair<AnnotatedString, StringAnnotation?>

/**
 * Format a message following Markdown-lite syntax
 * | @username -> bold, primary color and clickable element
 * | http(s)://... -> clickable link, opening it into the browser
 * | *bold* -> bold
 * | _italic_ -> italic
 * | ~strikethrough~ -> strikethrough
 * | `MyClass.myMethod` -> inline code styling
 *
 * @param text contains message to be parsed
 * @return AnnotatedString with annotations used inside the ClickableText wrapper
 */
@Composable
fun messageFormatter(
    text: String,
    primary: Boolean
): AnnotatedString {
    val tokens = symbolPattern.findAll(text)

    return buildAnnotatedString {

        var cursorPosition = 0

        val codeSnippetBackground =
            if (primary) {
                MaterialTheme.colorScheme.secondary
            } else {
                MaterialTheme.colorScheme.surface
            }

        for (token in tokens) {
            append(text.slice(cursorPosition until token.range.first))

            val (annotatedString, stringAnnotation) = getSymbolAnnotation(
                matchResult = token,
                colorScheme = MaterialTheme.colorScheme,
                primary = primary,
                codeSnippetBackground = codeSnippetBackground
            )
            append(annotatedString)

            if (stringAnnotation != null) {
                val (item, start, end, tag) = stringAnnotation
                addStringAnnotation(tag = tag, start = start, end = end, annotation = item)
            }

            cursorPosition = token.range.last + 1
        }

        if (!tokens.none()) {
            append(text.slice(cursorPosition..text.lastIndex))
        } else {
            append(text)
        }
    }
}

/**
 * Map regex matches found in a message with supported syntax symbols
 *
 * @param matchResult is a regex result matching our syntax symbols
 * @return pair of AnnotatedString with annotation (optional) used inside the ClickableText wrapper
 */
private fun getSymbolAnnotation(
    matchResult: MatchResult,
    colorScheme: ColorScheme,
    primary: Boolean,
    codeSnippetBackground: Color
): SymbolAnnotation {
    return when (matchResult.value.first()) {
        '@' -> SymbolAnnotation(
            AnnotatedString(
                text = matchResult.value,
                spanStyle = SpanStyle(
                    color = if (primary) colorScheme.inversePrimary else colorScheme.primary,
                    fontWeight = FontWeight.Bold
                )
            ),
            StringAnnotation(
                item = matchResult.value.substring(1),
                start = matchResult.range.first,
                end = matchResult.range.last,
                tag = SymbolAnnotationType.PERSON.name
            )
        )
        '*' -> SymbolAnnotation(
            AnnotatedString(
                text = matchResult.value.trim('*'),
                spanStyle = SpanStyle(fontWeight = FontWeight.Bold)
            ),
            null
        )
        '_' -> SymbolAnnotation(
            AnnotatedString(
                text = matchResult.value.trim('_'),
                spanStyle = SpanStyle(fontStyle = FontStyle.Italic)
            ),
            null
        )
        '~' -> SymbolAnnotation(
            AnnotatedString(
                text = matchResult.value.trim('~'),
                spanStyle = SpanStyle(textDecoration = TextDecoration.LineThrough)
            ),
            null
        )
        '`' -> SymbolAnnotation(
            AnnotatedString(
                text = matchResult.value.trim('`'),
                spanStyle = SpanStyle(
                    fontFamily = FontFamily.Monospace,
                    fontSize = 12.sp,
                    background = codeSnippetBackground,
                    baselineShift = BaselineShift(0.2f)
                )
            ),
            null
        )
        'h' -> SymbolAnnotation(
            AnnotatedString(
                text = matchResult.value,
                spanStyle = SpanStyle(
                    color = if (primary) colorScheme.inversePrimary else colorScheme.primary
                )
            ),
            StringAnnotation(
                item = matchResult.value,
                start = matchResult.range.first,
                end = matchResult.range.last,
                tag = SymbolAnnotationType.LINK.name
            )
        )
        else -> SymbolAnnotation(AnnotatedString(matchResult.value), null)
    }
}
