from manim import *


class Vector(VGroup):
    def __init__(
        self,
        cap=5,
        dir_right=True,
        is_rect=True,
        index=True,
        index_from=0,
        index_step=1,
        index_pos=UP,
        width=0.6,
        height=0.6,
        radius=0.3,
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
        self.is_rect = is_rect
        self.cell_width = width
        self.cell_height = height
        self.cell_radius = radius
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

    def _create_nodes(self, data):
        nodes = VGroup()

        for idx, val in enumerate(data):
            node = VGroup()

            node_cell = (
                Rectangle(width=self.cell_width, height=self.cell_height).set_fill(
                    BLACK, opacity=1
                )
                if self.is_rect
                else Circle(radius=self.cell_radius, color=WHITE).set_fill(
                    BLACK, opacity=1
                )
            )

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
            self._set_index(i, idx)

    def _getarc(self, arcfrom, arcto):
        return ArcBetweenPoints(
            self[arcfrom][0].get_center(), self[arcto][0].get_center(), angle=-PI
        )

    def focus(self, start, end=None, color=GREEN, fill=True, buff=0.1):
        end = start + 1 if end is None else end + 1

        bg = SurroundingRectangle(
            VGroup(*[self[idx][0] for idx in range(start, end)]), buff=buff
        ).set_stroke(color, width=4)

        if fill:
            bg.set_fill(color, opacity=0.3)

        return bg
            
    def get(self, index):
        return self.data[index]
            
    def set(self, index, value=None, label=None, scene=None, color=GREEN, fill=True, buff=0):
        value = self.data[index] if value is None else value
        label = self._get_indices_range()[index] if label is None else label

        bg = self.focus(index, color=color, fill=fill, buff=buff)
        if scene:
            scene.play(Write(bg))

        self.data[index] = value
        self._set_value(index, value)
        self._set_index(index, label)

        if scene:
            scene.wait(0.3)
            scene.play(FadeOut(bg))

    def swap(self, swapfrom, swapto, scene, highlight=True, color=YELLOW, fill=True, buff=0):
        if swapfrom == swapto:
            return

        bg = VGroup(
            self.focus(swapfrom, color=color, fill=fill, buff=buff),
            self.focus(swapto, color=color, fill=fill, buff=buff),
        )

        arcup = self._getarc(swapfrom, swapto)
        arcdown = self._getarc(swapto, swapfrom)

        if highlight:
            scene.play(Write(bg))

        scene.play(
            MoveAlongPath(self[swapfrom][1], arcup),
            MoveAlongPath(self[swapto][1], arcdown),
        )

        if highlight:
            scene.play(FadeOut(bg))

        x = self.data[swapfrom]
        self.set(swapfrom, self.data[swapto])
        self.set(swapto, x)

    def search(self, value, scene, start=0):
        idx = -1
        color = RED
        if value in self.data:
            idx = start + self.data[start:].index(value)
            color = GREEN

        bg = self.focus(start, color=BLUE, buff=0)
        scene.play(Write(bg))

        scene.play(Transform(bg, self.focus(idx, color=color, buff=0)))
        return (idx, bg)

    def get_min(self, scene, start=0):
        return self.search(min(self.data[start:]), scene, start)
