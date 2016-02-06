%{
package main

import (
	"fmt"
	"strconv"
	"log"
	"unicode/utf8"
	"bytes"
	"os"
	"io"
	"bufio"
)
%}


%union {
  input string
}

%token <input> NUM

%%

number: NUM
		{
			input, _ := strconv.Atoi($1)
			fmt.Println(input * 2)
		}

%%

const eof = 0

type doubleLex struct {
	line []byte
}

func (x *doubleLex) Lex(yylval *doubleSymType) int {
	for {
		c := x.next()
		switch (c) {
		case '0','1','2','3','4','5','6','7','8','9':
			return x.handleNumber(c, yylval)
		case eof:
			return eof
		}
	}
}

func (x *doubleLex) handleNumber(c rune, yylval *doubleSymType) int {
	var b bytes.Buffer
	b.WriteRune(c)
	L: for {
		// Keep reading numbers
		c = x.next()
		switch (c) {
		case '0','1','2','3','4','5','6','7','8','9':
			b.WriteRune(c)
		default:
			break L
		}
	}

	yylval.input = b.String()
	return NUM
}

func (x *doubleLex) next() rune {
	if len(x.line) == 0 {
		return eof
	}
	// Grab the next rune
	c, size := utf8.DecodeRune(x.line)
	// Remove the rune we just read from the line
	x.line = x.line[size:]
	return c
}

func (x *doubleLex) Error(s string) {
	fmt.Println(s)
}

func main() {
        in := bufio.NewReader(os.Stdin)
	for {
                if _, err := os.Stdout.WriteString("> "); err != nil {
		        log.Fatalf("WriteString: %s", err)
                }
                line, err := in.ReadBytes('\n')
                if err == io.EOF {
                        return
                }
                if err != nil {
	                log.Fatalf("ReadBytes: %s", err)
                }

		doubleParse(&doubleLex{line: line})
        }
}
