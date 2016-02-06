
// A grammar that only accepts numbers and

%{

package main

import (
	"bufio"
	"bytes"
	"io"
	"os"
	"fmt"
	"unicode/utf8"
)
%}

%union {
  num string
}

%token <num> NUM

%%

digit: NUM
        {
	  fmt.Println($1)
        }

%%

const eof = 0

type echoLex struct {
  line []byte
}

func (x *echoLex) Lex(yylval *echoSymType) int {
  for {
  c := x.next()
      switch c {
	case eof:
	return eof
	case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
	return x.readAllDigits(c, yylval)
      }
  }
}

func (x *echoLex) readAllDigits(c rune, yylval *echoSymType) int {
    var b bytes.Buffer
    b.WriteRune(c)
    L: for {
        c = x.next()
	switch (c) {
	  case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
	  b.WriteRune(c)
	  default:
	  break L
	}
    }
  yylval.num = b.String()
  if c == eof {
      return eof
  }
  return NUM
}

func (x *echoLex) Error(s string) {
  fmt.Printf("Parse error: %s", s)
}

func (x *echoLex) next() rune {
    if len(x.line) == 0 {
      return eof
    }
    c, size := utf8.DecodeRune(x.line)
    x.line = x.line[size:]
    return c
}


func main() {
 in := bufio.NewReader(os.Stdin)
    for {
      if _, err := os.Stdout.WriteString("> "); err != nil {
	fmt.Printf("WriteString: %s\n", err)
      }
      line, err := in.ReadBytes('\n')
      if err == io.EOF {
	  return
      }
      if err != nil {
	  fmt.Printf("ReadBytes: %s\n", err)
	}

      echoParse(&echoLex{line: line})
    }
}
