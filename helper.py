from manim import *


class Vector(VGroup):
    def __init__(
        self,
        cap=5,
        dir_right=True,
        index=True,
        index_from=0,
        index_step=1,
        index_pos=UP,
        width=0.6,
        height=0.6,
        font_size=22,
        buff=0,
        **kwargs,
    ):
        super().__init__(**kwargs)

        self.cap = cap
        self.size = 0
        self.data = [" "] * cap
        self.index = index
        self.index_from = index_from
        self.index_step = index_step
        self.index_pos = index_pos
        self.dir_right = dir_right
        self.direction = RIGHT if dir_right else UP
        self.cell_width = width
        self.cell_height = height
        self.font_size = font_size
        self.index_size = font_size * 0.7
        self.buff = buff

        self.add(*self._create_nodes(self.data))
        self._update_indices()

    def _get_indices_range(self):
        return list(
            range(
                self.index_from,
                self.index_from + self.cap * self.index_step,
                self.index_step,
            )
        )

    def _create_nodes(self, data):
        nodes = VGroup()

        for idx, val in enumerate(data):
            node = VGroup()

            node_cell = Rectangle(
                width=self.cell_width, height=self.cell_height
            ).set_fill(BLACK, opacity=1)
            node_value = Text(str(val), font_size=self.font_size, z_index=1).move_to(
                node_cell.get_center()
            )
            node_label = Text(str(idx), font_size=self.index_size).next_to(
                node_cell, self.index_pos
            )

            node.add(node_cell, node_value)
            if self.index:
                node.add(node_label)

            nodes.add(node)

        return nodes.arrange(self.direction, self.buff)

    def _update_indices(self):
        if not self.index:
            return

        for i, idx in enumerate(self._get_indices_range()):
            self[i][2].become(
                Text(str(idx), font_size=self.index_size).next_to(
                    self[i][0], self.index_pos
                )
            )

    def _set_value(self, index, value):
        self[index][1].become(
            Text(str(value), font_size=self.font_size, z_index=1).move_to(
                self[index][0].get_center()
            )
        )

    def _set_index(self, index, value):
        if not self.index:
            return

        self[index][2].become(
            Text(str(value), font_size=self.index_size).next_to(
                self[index][0], self.index_pos
            )
        )

    def _getarc(self, arcfrom, arcto):
        return ArcBetweenPoints(
            self[arcfrom][0].get_center(), self[arcto][0].get_center(), angle=-PI
        )

    def get(self, index):
        return self.data[index]

    def focus(self, start, end=None, color=GREEN, buff=0.1):
        end = start + 1 if end is None else end + 1

        return (
            SurroundingRectangle(
                VGroup(*[self[idx][0] for idx in range(start, end)]), buff=buff
            )
            .set_fill(color, opacity=0.3)
            .set_stroke(color, width=4)
        )

    def set(self, index, value=None, label=None, scene=None):
        value = self.data[index] if value is None else value
        label = self._get_indices_range()[index] if label is None else label

        bg = self.focus(index, buff=0)
        if scene:
            scene.play(Write(bg))

        self.data[index] = value
        self._set_value(index, value)
        self._set_index(index, label)

        if scene:
            scene.play(FadeOut(bg))

    def swap(self, swapfrom, swapto, scene):
        if swapfrom == swapto:
            return

        bg = VGroup(
            self.focus(swapfrom, color=YELLOW, buff=0),
            self.focus(swapto, color=YELLOW, buff=0),
        )

        arcup = self._getarc(swapfrom, swapto)
        arcdown = self._getarc(swapto, swapfrom)

        scene.play(Write(bg))

        scene.play(
            MoveAlongPath(self[swapfrom][1], arcup),
            MoveAlongPath(self[swapto][1], arcdown),
        )

        scene.play(FadeOut(bg))

        x = self.data[swapfrom]
        self.set(swapfrom, self.data[swapto])
        self.set(swapto, x)


# class BubbleSort(Scene):
#     def construct(self):
#         d = [64, 34, 25, 12, 22, 11, 90]
#         n = len(d)
        
#         v = Vector(cap=n)

#         for i in range(n):
#             v.set(i, d[i])

#         self.play(Write(v))
#         self.wait(2)

#         ilbl = Text("i", font_size=18).next_to(v[0], UP)
#         jlbl = Text("j", font_size=18).next_to(v[0], DOWN)
        
#         for i in range(n):
#             swapped = False
            
#             self.play(ilbl.animate.next_to(v[i], UP))
            
#             for j in range(n-i-1):
#                 self.play(jlbl.animate.next_to(v[j], DOWN))
#                 if v.get(j) > v.get(j+1):
#                     v.swap(j, j+1, self)
#                     swapped = True

#             self.play(FadeIn(v.focus(n-i-1, buff=0)))

#             if not swapped:
#                 break

#         self.play(FadeIn(v.focus(0, buff=0)))        
#         self.wait(2)



class BubbleSortComplexity(Scene):
    def construct(self):
        expr = VGroup(
            MathTex(r"i=0 \longrightarrow j = n-1"),
            MathTex(r"i=1 \longrightarrow j = n-2"),
            MathTex(r"\vdots"),
            MathTex(r"i=k \longrightarrow j = n-1-k"),            
            MathTex(r"i=n-2 \longrightarrow j = 1"),
            MathTex(r"i=n-1 \longrightarrow j = 0"),
            MathTex(r"S = n-1 + n-2 + \dots + 3 + 2 + 1"),
            MathTex(r"\text{Sum of first } n \text{ natural numbers } \frac{n (n+1)}{2} \text{ where } n = (n-1)"),
            MathTex(r"S = \frac{(n-1)(n-1+1)}{2} = \frac{n^2 - n}{2}"),
            MathTex(r"\text{BigO ignore constants and go with dominating factor } O(n^2)")
        ).scale(0.6).arrange(DOWN, aligned_edge=LEFT)

        self.play(Write(expr))
        self.wait(2)
