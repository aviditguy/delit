from manim import *
from helper import Vector


class BubbleSort(Scene):
    def construct(self):
        d = [64, 34, 25, 12, 22, 11, 90]
        n = len(d)
        
        v = Vector(cap=n)

        for i in range(n):
            v.set(i, d[i])

        self.play(Write(v))
        self.wait(2)

        ilbl = Text("i", font_size=18).next_to(v[0], UP)
        jlbl = Text("j", font_size=18).next_to(v[0], DOWN)
        
        for i in range(n):
            swapped = False
            
            self.play(ilbl.animate.next_to(v[i], UP))
            
            for j in range(n-i-1):
                self.play(jlbl.animate.next_to(v[j], DOWN))
                if v.get(j) > v.get(j+1):
                    v.swap(j, j+1, self)
                    swapped = True

            self.play(FadeIn(v.focus(n-i-1, buff=0)))

            if not swapped:
                break

        self.play(FadeIn(v.focus(0, buff=0)))        
        self.wait(2)
