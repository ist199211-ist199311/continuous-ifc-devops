// This theme contains ideas from the former "bristol" theme, contributed by
// https://github.com/MarkBlyth

#import "@preview/polylux:0.3.1": *

#let clean-footer = state("clean-footer", [])
#let clean-short-title = state("clean-short-title", none)
#let clean-color = state("clean-color", teal)
#let clean-logo = state("clean-logo", none)

// go-lang colors
#let go-gopher-blue = rgb("#00add8")
#let go-light-blue = rgb("#5dc9e2")
#let go-fuchsia = rgb("#ce3262")
#let go-aqua = rgb("#00a29c")
#let go-black = rgb("#000000")
#let go-yellow = rgb("#fddd00")
#let go-gradient = dir => gradient.linear(go-gopher-blue, go-aqua, dir: dir)

#let cloud-secondary = white.mix(go-gopher-blue)

#let clouds = [
  #place(bottom, dx: 270pt, dy: -20pt, circle(radius: 35pt, fill: cloud-secondary))
  #place(bottom, dx: 370pt, dy: -40pt, circle(radius: 35pt, fill: cloud-secondary))
  #place(bottom, dx: 420pt, dy: -15pt, circle(radius: 30pt, fill: cloud-secondary))
  #place(bottom, dx: 530pt, dy: 30pt, circle(radius: 40pt, fill: cloud-secondary))
  #place(bottom, dx: 770pt, dy: -10pt, circle(radius: 40pt, fill: cloud-secondary))
  #place(bottom, dx: -30pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 40pt, circle(radius: 45pt, fill: white))
  #place(bottom, dx: 110pt, circle(radius: 45pt, fill: white))
  #place(bottom, dx: 160pt, dy: -10pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 200pt, dy: 20pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 290pt, dy: 15pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 350pt, dy: 60pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 420pt, dy: 50pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 600pt, dy: 50pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 650pt, dy: 30pt, circle(radius: 55pt, fill: white))
  #place(bottom, dx: 700pt, dy: 55pt, circle(radius: 55pt, fill: white))
]

#let clean-theme(
  aspect-ratio: "16-9",
  footer: [],
  short-title: none,
  logo: none,
  color: teal,
  body
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: 0em,
    header: none,
    footer: none,
    
  )
  set text(size: 25pt, font: "Noto Sans")
  show footnote.entry: set text(size: .6em)

  clean-footer.update(footer)
  clean-color.update(color)
  clean-short-title.update(short-title)
  clean-logo.update(logo)

  body
}


#let title-slide(
  title: none,
  subtitle: none,
  authors: (),
  date: none,
  watermark: none,
  secondlogo: none,
) = {
  let content = locate( loc => {
    let color = go-yellow
    let logo = clean-logo.at(loc)
    let authors = if type(authors) in ("string", "content") {
      ( authors, )
    } else {
      authors
    }

    set text(white)
    place(top + left, box(fill: go-gradient(direction.btt), height: 100%, width: 100%))

    place(bottom, dy: 30pt, clouds)

    if watermark != none {
      set image(width: 100%)
      place(watermark)
    }

    [
      #set image(height: 2.2em)
      #place(bottom + left, dx: 0.5em, dy: -0.5em, logo)
    ]

    v(-15%)
    align(center + horizon)[
      #block(
        inset: 1em,
        breakable: false,
        [
          #text(2.5em)[*#title*] \
          #{
            if subtitle != none {
              parbreak()
              text(.9em)[#subtitle]
            }
          }
        ]
      )
      #v(-5%)
      #set text(size: .8em)
      #grid(
        columns: (1fr,) * calc.min(authors.len(), 3),
        column-gutter: 1em,
        row-gutter: 1em,
        ..authors
      )
      #v(1em)
      #date
    ]
  })
  logic.polylux-slide(content)
}

#let slide(title: none, body) = {
  let header = align(top, locate( loc => {
    let color = go-gopher-blue
    let logo = none
    let short-title = clean-short-title.at(loc)

    show: block.with(stroke: (bottom: 1mm + color), width: 100%, inset: (y: .3em))
    set text(size: .5em)

    grid(
      columns: (1fr, 1fr),
      if logo != none {
        set align(left)
        set image(height: 4em)
        logo
      } else { box(height: 4em) },
      if short-title != none {
        align(horizon + right, grid(
          columns: 1, rows: 1em, gutter: .5em,
          short-title,
          utils.current-section
        ))
      } else {
        align(horizon + right, utils.current-section)
      }
    )
  }))

  let footer = locate( loc => {
    let color = go-gopher-blue

    block(
      stroke: ( top: 1mm + color ), width: 100%, inset: ( y: .3em ),
      text(.5em, {
        clean-footer.display()
        h(1fr)
        logic.logical-slide.display()
      })
    )
  })

  set page(
    margin: ( top: 4em, bottom: 2em, x: 1em ),
    header: header,
    footer: footer,
    footer-descent: 1em,
    header-ascent: 1.5em,
  )

  let body = pad(x: .0em, y: .5em, body)
  

  let content = {
    show heading: it => text(go-gopher-blue, it)
    if title != none {
      heading(level: 2, title)
    }
    body
  }
  
  logic.polylux-slide(content)
}

#let outline-slide(title: none, body) = {


  set page(
    margin: ( top: 4em, bottom: 2em, x: 1em ),
    footer-descent: 1em,
    header-ascent: 1.5em,
    fill: go-gradient(direction.ttb),
  )
  set text(white)

  

  let body = pad(x: .0em, y: .5em, body)
  

  let content = {
    v(10%)
    if title != none {
      show heading: it => underline(stroke: 3pt + go-yellow, it)
      heading(level: 2, title)
    }
    place(top, dy: -130pt, dx: 100%, rotate(180deg, clouds))
    body
  }
  
  logic.polylux-slide(content)
}

#let focus-slide(background: teal, foreground: white, body) = {
  set page(fill: background, margin: 2em)
  set text(fill: foreground, size: 1.5em)
  let content = { v(.1fr); body; v(.1fr) }
  // logic.polylux-slide(align(horizon, body))
  logic.polylux-slide(content)
}

#let new-section-slide(name) = {
  set page(margin: 2em, fill: go-gradient(direction.ltr))
  let content = locate( loc => {
    let color = go-yellow
    set align(center + horizon)
    show: block.with(stroke: ( bottom: 1mm + color ), inset: 1em,)
    set text(size: 1.5em, white)
    strong(name)
    utils.register-section(name)
  })
  logic.polylux-slide(content)
}