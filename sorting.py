from manim import *
from helper import Vector


class BubbleSort(Scene):
    def construct(self):
        data = [64, 25, 22, 11, 12, 55, 30]
        n = len(data)
        
        vec = Vector(cap=n)

        for i, v in enumerate(data):
            vec.set(i, v)
        
        self.play(Write(vec))

        ilbl = Text("i", font_size=18).next_to(vec[0], UP)
        jbg = vec.focus(0, color=BLUE, buff=0)
        j1bg = vec.focus(1, color=YELLOW, buff=0)        

        for i in range(n):
            self.play(ilbl.animate.next_to(vec[i], UP))
            
            for j in range(n-1-i):
                self.play(
                    jbg.animate.move_to(vec[j][0].get_center()),
                    j1bg.animate.move_to(vec[j+1][0].get_center())
                )
                if vec.get(j) > vec.get(j+1):
                    vec.swap(j, j+1, self, highlight=False)

            self.play(Write(vec.focus(n-i-1, buff=0)))

        self.play(FadeOut(jbg),
                  FadeOut(j1bg))
                  
        self.wait(2)


class SelectionSort(Scene):
    def construct(self):
        data = [64, 25, 22, 11, 12, 55, 30]
        n = len(data)

        vec = Vector(cap=n)

        for i, v in enumerate(data):
            vec.set(i, v)
        
        self.play(Write(vec))

        ilbl = Text("i", font_size=18).next_to(vec[0], UP)
        bg = vec.focus(0, color=BLUE, buff=0)
        
        for i in range(n-1):
            self.play(
                ilbl.animate.next_to(vec[i], UP),
                Transform(bg, vec.focus(i, color=BLUE, buff=0))
            )
            
            midx, mbg = vec.get_min(self, start=i)
            vec.swap(i, midx, self, highlight=False)
            self.play(FadeOut(mbg), FadeIn(vec.focus(i, buff=0)))

        self.play(FadeOut(bg), FadeIn(vec.focus(n-1, buff=0)))
        
        self.wait(2)
